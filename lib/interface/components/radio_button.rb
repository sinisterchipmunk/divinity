class Interface::Components::RadioButton < Interface::Components::InputComponent
  include Listeners::Mouse::ButtonMouseListener
  attr_reader :state
  attr_reader :action_listeners
  attr_accessor :button_value
  theme_selection :secondary

  def initialize(object, method, value, options = {}, &block)
    @button_value = value
    
    super(object, method, options)
    @action_listeners = [ self ]
    self.mouse_listeners <<= self
    @caption = options[:caption] || value.to_s.titleize
    @state = 0
    yield if block_given?
  end

  def action_performed(evt)
    self.value = button_value
  end

  def minimum_size
    Dimension.new(1, 1)
  end

  def maximum_size
    Dimension.new(1024,1024)
  end

  def preferred_size
    Dimension.new(Font.select.width(@caption) + 10, Font.select.height + 10)
  end

  def update(delta)
    if value == button_value
      background_texture.set_option :brightness, DOWN_SHADE
    else
      option = NORM_SHADE
      option = OVER_SHADE if @state & Interface::Components::Button::ButtonState::MOUSE_OVER > 0
      option = DOWN_SHADE if @state & Interface::Components::Button::ButtonState::MOUSE_DOWN > 0
      background_texture.set_option :brightness, option
    end
    super
  end

  def paint
    paint_background
    size = Font.select.sizeof(@caption)
    x = (self.bounds.width - size.width) / 2
    y = (self.bounds.height - size.height) / 2
    (x += 2 and y += 2) if @state & Interface::Components::Button::ButtonState::MOUSE_DOWN > 0 or value == button_value
    glColor4f(0,0,0,1)
    Font.select.put(x, y, @caption)
    glColor4f(1,1,1,1)
  end
end
