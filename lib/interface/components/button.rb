class Interface::Components::Button < Interface::Components::Component
  include Listeners::Mouse::ButtonMouseListener
  attr_reader :state
  attr_reader :action_listeners

  theme_selection :secondary

  class ButtonState
    MOUSE_DOWN = 1
    MOUSE_OVER = 2
  end

  def initialize(caption="Btn")
    super()
    @action_listeners = []
    self.mouse_listeners <<= self
    @caption = caption
    @state = 0
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

  def paint
    paint_background
    size = Font.select.sizeof(@caption)
    x = (self.bounds.width - size.width) / 2
    y = (self.bounds.height - size.height) / 2
    (x += 2 and y += 2) if @state & ButtonState::MOUSE_DOWN > 0
    glColor4fv foreground_color
    Font.select.put(x, y, @caption)
    glColor4f(1,1,1,1)
  end
end
