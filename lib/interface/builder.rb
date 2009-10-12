# Assists in the construction of user interfaces by providing a DSL to build them with
class Interface::Builder
  include Helpers::AttributeHelper
  include Interface::Layouts

  def initialize(action = nil, &block)
    @action = action
    @block = block
  end

  def panel(constraints, &block)
    p = Interface::Containers::Panel.new
    self.class.new(&block).apply_to(@engine, p) if block_given?
    component.add(p, constraints)
  end

  def layout(type, *args)
    component.layout = type and return if type.kind_of? Layout
    component.layout = case type
      when :grid then GridLayout.new(*args)
      when :flow then FlowLayout.new(*args)
      when :border then BorderLayout.new(*args)
      else raise "Layout type should be one of [:grid, :flow, :border]"
    end
  end

  def label(text, options = { }, &block)
    options = { :constraints => options } unless options.kind_of? Hash

    constraints = options.delete :constraints
    text = text.to_s.titleize unless text.kind_of? String
    label = Interface::Components::Label.new(text, options, &block)
    @component.add label, constraints
  end

  def image(path, options = { }, &block)
    constraints = options.delete(:constraints)
    img = Interface::Components::Image.new(path, options, &block)
    @component.add img, constraints
  end

  def text_field(object, method, options = { }, &block)
    options = { :constraints => options } unless options.kind_of? Hash

    constraints = options.delete :constraints
    field = Interface::Components::TextField.new(object, method, options, &block)
    @component.add field, constraints
  end
  
  def radio_button(object, method, value, options = { }, &block)
    options = { :constraints => options } unless options.kind_of? Hash

    constraints = options.delete :constraints
    field = Interface::Components::RadioButton.new(object, method, value, options, &block)
    @component.add field, constraints
  end

  def button(action, options = { :label => kind })
    @next_interface = action
    options = { :label => options } if options.kind_of? String
    raise "Options should be a Hash" unless options.kind_of? Hash
    options[:label] ||= action.to_s.titleize
    action = options.delete(:action) if options.key? :action

    b = Interface::Components::Button.new(options.delete(:label) || action.to_s.titleize)
    constraints = options.delete :constraints
    builder = self.class.new(action).apply_to(@engine, b)
    options.each { |k,v| builder.send("#{k}=", v)}
    b.action_listeners << builder
    @component.add b, constraints
  end

  def apply_to(engine, component)
    @engine = engine
    @component = component
    instance_eval &@block if @block
    self
  end

  def component
    @component
  end

  def action_performed(event)
    @engine.fire_interface_action(@action)
  end

  def respond_to?(*args, &block)
    super or @component.respond_to?(*args, &block) or @engine.respond_to?(*args, &block)
  end

  def method_missing(name, *args, &block)
    return @component.send(name, *args, &block) if @component.respond_to? name
    return @engine.send(name, *args, &block) if @engine.respond_to? name
    super
  end
end
