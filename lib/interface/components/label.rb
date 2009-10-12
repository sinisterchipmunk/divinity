class Interface::Components::Label < Interface::Components::InputComponent
  theme_selection :text
  attr_reader :font_options, :label
  attr_accessor :color

  def initialize(label, options = {}, &block)
    @color = [ 0, 0, 0, 1 ]
    @font_options = {}
    super(options.delete(:target), options.delete(:method), options)
    @label = label

    yield if block_given?
  end

  def paint
    l = (@label.blank? ? value : @label).to_s
    
    paint_background
    glColor4fv(@color)
    Font.select.put((width - size.width) / 2, (height / 2) - (size.height / 2), l)
    glColor4f(1,1,1,1)
  end

  def size
    Font.select(font_options).sizeof((@label.blank? ? value : @label).to_s)
  end

  def minimum_size; size end
  def maximum_size; size end
  def preferred_size; size end
end
