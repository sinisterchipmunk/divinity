# Assists in the construction of user interfaces by providing a DSL to build them with
class Interface::Builder
  include Helpers::AttributeHelper
  include Interface::Layouts

  attr_reader :component, :engine, :action

  def initialize(action = nil, &block)
    @action = action
    @block = block
  end

  def panel(constraints = nil, &block)
    p = Interface::Containers::Panel.new
    self.class.new(&block).apply_to(@engine, p) if block_given?
    component.add(p, constraints)
  end

  def scroll_panel(constraints = nil, &block)
    p = Interface::Containers::ScrollPanel.new
    self.class.new(&block).apply_to(@engine, p) if block_given?
    component.add p, constraints
  end

  def partial(interface_name, constraints = nil, &block)
    p = Interface::Containers::Panel.new(Interface::Layouts::BorderLayout.new, &block)
    builder = @engine.find_interface(interface_name)
    builder.apply_to(@engine, p)
    component.add p, constraints
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

  def image_selector(object, method, images, constraints = nil, options = { }, &block)
    img = Interface::Components::ImageSelector.new(images, object, method, options, &block)
    @component.add img, constraints
  end

  def text_field(object, method, options = { }, &block)
    build_input_component object, method, options, Interface::Components::TextField, &block
  end

  def text_area(object, method, options = { }, &block)
    build_input_component object, method, options, Interface::Components::TextArea, &block
  end

  def radio_button(object, method, value, options = { }, &block)
    build_input_component object, method, options.merge(:value => value), Interface::Components::RadioButton, &block
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

  def toggle_button(object, method, caption = nil, constraints = nil, options = {}, &block)
    options.merge! :caption => (caption || method.to_s.titleize)
    b = Interface::Components::ToggleButton.new(object, method, options)
    @component.add b, constraints
  end

  def build_input_component(object, method, options, klass, &block)
    options = { :constraints => options } unless options.kind_of? Hash
    constraints = options.delete :constraints
    field = klass.new(object, method, options, &block)
    @component.add field, constraints
  end

  def apply_to(engine, component)
    @engine = engine
    @component = component
    instance_eval &@block if @block
    self
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
