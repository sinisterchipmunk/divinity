# Controllers are essentially the user old logic of the engine. They are used primarily to tie models to views,
# or to trigger engine events such as pausing, loading a new location, ending the program, etc.
#
# Controller actions are fired once, while an action is being performed. After the controller action has completed,
# its corresponding view is rendered to an offscreen buffer. That buffer is displayed every frame until a new action
# is performed, and the process repeats.
#
class Engine::Controller::Base
  include Helpers::EventListeningHelper
  include Engine::Controller::Helpers
  include Engine::Controller::EventDispatching
  extend  Engine::Controller::ClassMethods

  attr_accessor :action_name

  # Some controllers have parent controllers. For instance, if you add a Button to a Panel, that Button's controller
  # (an instance of ButtonController) would have its parent set to the Panel's controller (an instance of
  # PanelController). Note that the View and Model do not maintain this relationship; component hierarchy is a function
  # of the controllers. The actual assignment of the parent controller, however, takes place in
  # Helpers::ComponentHelper.
  #
  attr_accessor :parent

  attr_internal :request
  attr_internal :response
  attr_internal :params
  attr_internal :event
  attr_internal :engine

  attr_reader :mouse, :keyboard#, :event_queue
  delegate :width, :height, :bounds, :bounds=, :translate, :translate_absolute, :contains?, :to => :request
  delegate :insets, :preferred_size, :minimum_size, :maximum_size, :resultant_image, :valid?, :to => :response
  delegate :components, :to => :response

  public
    def dump_events(*which); false; end #:nodoc:

    def initialize(engine, request, response)
      @mouse = Engine::Controller::MouseProxy.new(self, engine.mouse)
      @keyboard = Engine::Controller::KeyboardProxy.new(self, engine.keyboard)
      #@event_queue = []
      
      @focused = self
      assign_shortcuts(engine, request, response)

      response.default_theme = params.delete(:theme) if params.key?(:theme)
    end

    def process_event(action, options = {})
      action = action.to_s if action.kind_of? Symbol
      if action_methods.include?(action)
        if @processing
          redirect_to action
          #event_queue << action
        else
          options = { :event => options } unless options.kind_of? Hash
          unless options[:event]
            model = (self.respond_to?(:model) ? self.model : nil)
            options[:event] = Events::Generic.new(action, model)
          end

          #TODO: Replace with real logging.
          puts "#{controller_name} - #{action}: #{options.inspect}" if dump_events(action)

          # decided to let the proxies scan the devices directly for the most up-to-date info
    #      case options[:event]
    #        when Events::MouseEvent then @mouse.update(options[:event])
    #        when Events::KeyEvent   then @keyboard.update(options[:event])
    #      end
          # All events are optional, and only result in actions if the controller responds_to? them.
          if self.class.action_methods.include? action
            process action, options
          end
        end
      end
    end
  
    def process(action, options = {})
      @processing = true
      options = { :event => options } unless options.kind_of? Hash

      params['action'] = action.to_s
      assign_names
      initialize_view
      @_event = options.delete :event
      find_models(options)
      erase_results if response.completed?
      perform_action
      @processing = false

      response.do_redirect if performed_redirect?

      
#      # these are calls to #fire_event! that could not be processed because an action was already processing.
#      # basically we just treat each of them as a call to redirect_to, and since there's nothing else to do,
#      # we do each redirect in turn. If one of those results in another action firing, it's added to the queue,
#      # and processed last.
#      event_queue.each do |action|
#        redirect_to action
#        response.do_redirect
#      end
    end

    # Fired events have the expected functionality (they are sent to any action listeners), and additionally
    # call this controller's #process_event method.
    def fire_event(name, *args)
      process_event(name, :event => Events::Generic.new(name, model, *args))
      super
    end

    # Converts the class name from something like "OneModule::TwoModule::NeatController" to "NeatController".
    def controller_class_name
      self.class.controller_class_name
    end

    # Converts the class name from something like "OneModule::TwoModule::NeatController" to "neat".
    def controller_name
      self.class.controller_name
    end

    # Converts the class name from something like "OneModule::TwoModule::NeatController" to "one_module/two_module/neat".
    def controller_path
      self.class.controller_path
    end

  protected
    def render(options = nil, extra_options = {})
      raise Engine::Controller::DoubleRenderError, "Can only render or redirect once per action" if performed?
      validate_render_arguments(options, extra_options)

      if options.nil?
        options = { :template => default_view }
      elsif options.is_a?(String) || options.is_a?(Symbol)
        case options.to_s.index('/')
          when 0 then extra_options[:file] = options
          when nil then extra_options[:action] = options
          else extra_options[:template] = options
        end
        options = extra_options
      elsif !options.is_a?(Hash)
        extra_options[:partial] = options
        options = extra_options
      end

      if options.has_key?(:text)             then render_text(options[:text])
      else
        if file = options[:file]             then render_view(file, options[:locals] || {})
        elsif template = options[:template]  then render_view(template, options[:locals] || {})
        elsif view = options[:view]          then render_view(view, options[:locals] || {})
        elsif action_name = options[:action] then render_view(default_view(action_name.to_s))
        elsif partial = options[:partial]    then render_view(partial, options[:locals] || {})
        elsif options[:nothing]              then render_view(nil)
        else                                      render_view(default_view)
        end
      end
    end
  
    # Clears the rendered results, allowing for another render to be performed.
    def erase_render_results
      @performed_render = false
      @performed_redirect = false
    end

    # Clears the redirected results from the headers, resets the status to 200 and returns
    # the URL that was used to redirect or nil if there was no redirected URL
    # Note that +redirect_to+ will change the body of the response to indicate a redirection.
    # The response body is not reset here, see +erase_render_results+
    def erase_redirect_results
      @performed_redirect = false
      response.redirected_to = nil
      response.redirected_to_params = HashWithIndifferentAccess.new
    end

    # Erase both render and redirect results
    def erase_results
      erase_render_results
      erase_redirect_results
    end

    def redirect_to(options)
      raise Engine::Controller::DoubleRenderError if performed?
      options = { :action => options } unless options.kind_of? Hash
      #logger.info("Redirected to #{url}") if logger && logger.info?
      response.redirect(options.reverse_merge(:controller => controller_path, :action => 'index'))
      @performed_redirect = true
    end


  private
    def find_models(options = {})
      # look for a model by the same name as the controller. Example: Components::ButtonController => Components::Button
      model = nil
      begin
        model = controller_path.camelize.constantize.new(*request.args)
      rescue NameError, ArgumentError
        # fail silently if the model class doesn't exist
        unless $!.message =~ /#{Regexp::escape(controller_path.camelize)}/
          raise
        end
      rescue
        puts $!.class, $!.message, $!.backtrace if $VERBOSE
      end
      
      if model
        options[:model] ||= model
        options[controller_name] ||= model
      end

      # define all relevant model methods
      options.each do |key, value|
        define_singleton_method(key) { value }
        # Now proxy the same methods into the view. We allow then to pass through the controller in case the developer
        # decides to override any of them.
        response.view.define_singleton_method(key) { controller.send(key) }
      end
    end

    def render_view(path, locals = {})
      @performed_render = true
      ## TODO: something like view.copy_ivars_from(self)
      response.view.path = path
      response.view.locals = locals
      response.process
    end

    hide_action :render_view

    def render_text(text)
      raise Engine::Controller::NotImplemented
    end

    def perform_action
      if action_methods.include?(action_name)
        send(action_name)
        render unless performed?
      elsif respond_to? :method_missing
        method_missing action_name
        render unless performed?
      else
        begin
          render
        rescue Engine::View::MissingViewError => e
          if respond_to?(action_name)
            raise
          else
            raise Engine::Controller::UnknownAction,
                  "No action responded to #{action_name}. Actions: #{action_methods.sort.to_sentence(:locale => :en)}",
                  caller
          end
        end
      end
    end

    def initialize_view
      response.view = Engine::View::Base.new(self)
      response.view.helpers.send :include, self.class.master_helper_module
      erase_results
    end

    def validate_render_arguments(options, extra_options)
      if options && !options.is_a?(String) && !options.is_a?(Hash) && !options.is_a?(Symbol)
        raise Engine::Controller::RenderError, "You called render with invalid options : #{options.inspect}"
      end

      if !extra_options.is_a?(Hash)
        raise Engine::Controller::RenderError, "You called render with invalid options : #{options.inspect}, #{extra_options.inspect}"
      end
    end

    def assign_shortcuts(engine, request, response)
      @_engine = engine
      @_request, @_params = request, request.parameters
      @_response         = response
      @_response.request = @_request
      @_request.controller = self
    end

    def performed?
      performed_render? || performed_redirect?
    end

    def performed_render?
      @performed_render
    end

    def performed_redirect?
      @performed_redirect
    end

    def assign_names
      @action_name = (params['action'] || 'index')
    end

    def action_methods
      self.class.action_methods
    end

    def self.action_methods
      @action_methods ||=
        # All public instance methods of this class, including ancestors
        public_instance_methods(true).map { |m| m.to_s }.to_set -
        # Except for public instance methods of Base and its ancestors
        Engine::Controller::Base.public_instance_methods(true).map { |m| m.to_s } +
        # Be sure to include shadowed public instance methods of this class
        public_instance_methods(false).map { |m| m.to_s } -
        # And always exclude explicitly hidden actions
        hidden_actions
    end

    def default_view(action_name = self.action_name, cache_key = "#{self.class.name}-#{action_name}")
      c = Divinity.cache.read(cache_key)
      return c if c
      Divinity.cache.write(cache_key, r = self.class.view_paths.find_view(engine, default_view_name(action_name)))
      r
    end

    def default_view_name(action_name = self.action_name)
      if action_name
        action_name = action_name.to_s
        if action_name.include?('/') && view_path_includes_controller?(action_name)
          action_name = strip_out_controller(action_name)
        end
      end
      "#{self.controller_path}/#{action_name}"
    end

    def strip_out_controller(path)
      path.split('/', 2).last
    end

    def view_path_includes_controller?(path)
      self.controller_path.split('/')[-1] == path.split('/')[0]
    end
end
