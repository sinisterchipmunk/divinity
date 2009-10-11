class Interface::Components::Label < Interface::Components::Component
  theme_selection :text
  attr_reader :font_options, :label
  attr_accessor :color

  def initialize(label, options = {}, &block)
    @label = label
    @color = [ 0, 0, 0, 1 ]
    @font_options = {}
    super(options)

    yield if block_given?
  end

  def paint
    paint_background
    glColor4fv(@color)
    Font.select.put((width - size.width) / 2, (height / 2) - (size.height / 2), @label)
    glColor4f(1,1,1,1)
  end

  def size
    Font.select(font_options).sizeof(label)
  end

  def minimum_size; size end
  def maximum_size; size end
  def preferred_size; size end
end
