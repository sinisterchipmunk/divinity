# Controllers are essentially the user interface logic of the engine. They are used primarily to tie models to views,
# or to trigger engine events such as pausing, loading a new location, ending the program, etc.
#
# Controller actions are fired once, while an action is being performed. After the controller action has completed,
# its corresponding view is rendered to an offscreen buffer. That buffer is displayed every frame until a new action
# is performed, and the process repeats.
#
class Engine::Controller::Base
  include Engine::Controller::Errors
  include Helpers::EventListeningHelper
  extend  Engine::Controller::ClassMethods

  attr_accessor :action_name
  attr_internal :request
  attr_internal :response
  attr_internal :params
  attr_internal :event

  public
    def initialize(request, response)
      assign_shortcuts(request, response)
      process('index', nil)
    end

    def process(action, event)
      params['action'] = action
      assign_names
      @_event = event
      perform_action
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

  private
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
        rescue Engine::View::MissingInterfaceError => e
          # Was the implicit template missing, or was it another template?
          raise UnknownAction,
                "No action responded to #{action_name}. Actions: #{action_methods.sort.to_sentence(:locale => :en)}",
                caller
        end
      end
    end

    def assign_shortcuts(request, response)
      @_request, @_params = request, request.parameters
      @_response         = response
    end

    def performed?
      @performed_render || @performed_redirect
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
        Base.public_instance_methods(true).map { |m| m.to_s } +
        # Be sure to include shadowed public instance methods of this class
        public_instance_methods(false).map { |m| m.to_s } -
        # And always exclude explicitly hidden actions
        hidden_actions
    end
end
