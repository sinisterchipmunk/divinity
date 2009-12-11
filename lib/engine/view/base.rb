# A View is used solely for laying out and rendering the content to be displayed. As a rule, this means laying out and
# rendering *child* components. A View never directly modifies its own size or position; it is, instead, expected to use
# the bounds given to it to their fullest effect. For instance, views displayed at the highest level -- usually complete
# user interfaces -- will be given bounds equal to the size of the entire screen. Those views are expected to lay out
# their child components such that they utilize the entire screen.
#
# In practice, this is usually handled by Layouts so that the view need give only very general constraints. By default,
# all views are given a Border Layout, which allows the components within a view to be locked to one of the four edges
# or the center of the view.
#
# A layout can be overridden by using the "layout" keyword.
#
# Views are also charged with the task of passing on their data models to subcomponents, if this is necessary. Usually,
# this only has to be done for data which must be directly represented and changed by one of those subcomponents -- for
# example, a text field might represent a Web browser address; the view that lays out the text field is in charge of
## mapping the text field itself to the address field of the Web browser.
#
# Here is an example of a view file, rendering an imaginary Web browser old:
#
#   panel :north do
#     layout :flow # the north panel should use a "grid" layout for its subcomponents
#     label      "Address: "
#     text_field browser, :address # map the text field to the "address" field of the browser model.
#     button     "OK"              # will fire the "button_clicked" action in the controller when clicked.
#   end
#   
#   panel :center do
#     # lay out the web page in the center of the screen
#   end
#
class Engine::View::Base
  # Should we be doing this??? An alternative would be to include it into a singleton view during #process...
  include Helpers::ComponentHelper


  class ProxyModule < Module
    def initialize(receiver)
      @receiver = receiver
    end

    def include(*args)
      super(*args)
      @receiver.extend(*args)
    end
  end

  #include Helpers::ComponentHelper
  delegate :engine, :request, :response, :mouse, :keyboard, :params, :to => :controller
  delegate :components, :to => :layout
  delegate :center, :width, :height, :bounds, :to => :request
  delegate :current_theme, :to => :engine
  delegate :theme, :to => :response

  attr_accessor :path, :locals
  attr_reader :controller, :helpers

  def initialize(controller)
    @controller = controller
    @helpers = ProxyModule.new(self)
    layout :border
  end

  def layout(a = nil, *args, &block)
    return @layout if a.nil?
    a = "interface/layouts/#{a}_layout".camelize.constantize unless a.kind_of? Interface::Layouts::Layout
    @layout = a.new(*args, &block)
    @layout
  end

  def process(options = {:layout => true})
    load
    copy_ivars_from_controller
    locals = ""
    @locals.keys.each { |k| locals += "#{k} = @locals[#{k.inspect}];" }
    layout :border if options[:layout]
    eval locals
    eval @content, binding, @path, 1
    instance_eval &request.block if request.block
    do_layout if options[:layout]
  end

  # Returns the result of a render that's dictated by the options hash. The primary options are:
  #
  # * <tt>:partial</tt> - See ActionView::Partials.
  # * <tt>:file</tt> - Renders an explicit file, add :locals to pass in those.
  #
  # If no options hash is passed, the default is to render a partial and use the second parameter
  # as the locals hash.
  def render(options = {}, local_assigns = {}, &block) #:nodoc:
    local_assigns ||= {}

    case options
    when Hash
      options = options.reverse_merge(:locals => local_assigns)
      if options[:layout]
        raise "Not yet implemented" # FIXME: implement layouts
        _render_with_layout(options, local_assigns, &block)
      elsif options[:file]
        render_file(options)
        #template = self.view_paths.find_template(options[:file], template_format)
        #template.render_template(self, options[:locals])
      elsif options[:partial]
        render_file(options.merge({:file => _pick_partial_path(options.delete(:partial))}))
      end
    else
      render_file(:file => _pick_partial_path(options), :locals => local_assigns)
    end
  end

  def render_file(options)
    r = Divinity.cache.read(options[:file])
    Divinity.cache.write(options[:file], r = File.read(options[:file])) unless r
    eval r, binding, options[:file], 1
  end

  def _pick_partial_path(partial_path) #:nodoc:
    if partial_path.include?('/')
      path = File.join(File.dirname(partial_path), "_#{File.basename(partial_path)}")
    elsif controller
      path = "#{controller.class.controller_path}/_#{partial_path}"
    else
      path = "_#{partial_path}"
    end

    controller.class.view_paths.find_view(engine, path)
  end

  private
  def copy_ivars_from_controller
    if @controller
      variables = @controller.instance_variable_names
      variables -= @controller.protected_instance_variables if @controller.respond_to?(:protected_instance_variables)
      variables.each { |name| instance_variable_set(name, @controller.instance_variable_get(name)) }
    end
  end

  def load
    @content = File.read(@path)
  end

  def do_layout
    layout.layout_container(response)
    layout.components.each do |component|
      component.process 'index', {}
    end
  end
end
