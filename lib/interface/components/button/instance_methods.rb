module Interface::Components::Button::InstanceMethods
  def self.included(base)
    base.send :attr_reader, :state, :caption, :action_listeners
    base.send :theme_selection, :secondary
    base.send :include, Listeners::Mouse::ButtonMouseListener
  end

  def init_variables(caption)
    @action_listeners = []
    self.mouse_listeners << self
    @caption = caption
    @state = @mouse_state = 0
  end

  def caption=(label)
    @caption = label
    invalidate
  end

  def validate
    super
  end

  def minimum_size
    Geometry::Dimension.new(1, 1)
  end

  def maximum_size
    Geometry::Dimension.new(1024,1024)
  end

  def preferred_size
    Geometry::Dimension.new(font.width(caption) + 10, font.height + 10)
  end

  def paint(i = nil)
    offset = @state * 2 # index 1 is "down", so offset the label by 2 pixels.

    size = font.sizeof(caption)
    lx = (self.insets.width  - size.width)  / 2 + offset
    ly = (self.insets.height - size.height) / 2 + offset
    font.put(lx, ly, caption)
  end
end