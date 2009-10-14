class Interface::Components::Label < Interface::Components::InputComponent
  theme_selection :text
  attr_reader :label
  attr_accessor :color

  def initialize(label, options = {}, &block)
    super(options.delete(:target), options.delete(:method), options)
    @label = label

    yield if block_given?
  end

  def paint
    l = (@label.blank? ? value : @label).to_s
    
    Font.select.put((insets.width - size.width) / 2, (insets.height / 2) - (size.height / 2), l)
  end

  def size
    font.sizeof((@label.blank? ? value : @label).to_s)
  end

  def minimum_size; size end
  def maximum_size; size end
  def preferred_size; size end
end
