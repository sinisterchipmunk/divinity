# Assists in the construction of user interfaces by providing a DSL to build them with
class Interface::Builder
  include Helpers::AttributeHelper
  include Interface::Layouts
  extend Interface::Builder::ClassMethods

  attr_reader :component, :engine, :action
  generic_container :panel
  model_container :flip_panel
  model_component :label, :image, :image_selector, :text_field, :text_area, :radio_button, :toggle_button

  def initialize(action = nil, &block)
    @action = action
    @block = block
  end

  def partial(constraints, interface_name, &block)
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
  
  def apply_to(engine, component)
    @engine = engine
    @component = component
    instance_eval &@block if @block
    self
  end

  def respond_to?(*args, &block)
    super or @component.respond_to?(*args, &block) or @engine.respond_to?(*args, &block)
  end

  def method_missing(name, *args, &block)
    return @component.send(name, *args, &block) if @component.respond_to? name
    return @engine.send(name, *args, &block) if @engine.respond_to? name
    super
  end

  def button(constraints = nil, action = nil, options = { }, &block)
    @next_interface = action
    options = { :caption => options } if options.kind_of? String
    options[:caption] ||= action.to_s.titleize
    klass = options.delete(:class) || Interface::Components::Button
    action = options.delete(:action) if options.key? :action

    b = klass.new(options.delete(:caption) || action.to_s.titleize)
    builder = self.class.new(action).apply_to(engine, b)
    options.each { |k,v| builder.send("#{k}=", v)}
    b.on :action_performed do engine.fire_interface_action(builder.action) end
    component.add b, constraints
  end

  def image_button(constraints = nil, action = nil, options = { }, &block)
    options.reverse_merge! :class => Interface::Components::ImageButton
    button(constraints, action, options, &block)
  end
end
