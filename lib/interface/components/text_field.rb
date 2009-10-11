class Interface::Components::TextField < Interface::Components::Component
  theme_selection :text
  attr_reader :font_options, :value, :padding
  attr_accessor :color
  attr_accessor :caret_position

  include Listeners::KeyListener

  def initialize(options = {}, &block)
    @value = options[:value] || ""
    @color = [ 0, 0, 0, 1 ]
    @font_options = {}
    @caret_position = 0
    @padding = 4
    super(options)

    key_listeners << self

    yield if block_given?
  end

  def key_typed(evt)
    puts 'typed'
    puts evt.inspect
  end

  def key_released(evt)
    puts 'released'
    puts evt.inspect
  end

  def key_pressed(evt)
    puts 'pressed'
    puts evt.inspect

    @value.concat evt.sym.chr
    @caret_position += 1
  end

  def paint
    paint_background
    glColor4fv(@color)
    leftmost = border_size + padding
    Font.select.put(leftmost, (height / 2) - (size.height / 2), value)

    if Interface::GUI.focus == self
      x = Font.select(font_options).sizeof(value[0...caret_position]).width + leftmost
      glColor4fv(color)
      glDisable(GL_TEXTURE_2D)
      glBegin(GL_LINES)
        glVertex2i(x, border_size + padding)
        glVertex2i(x, height - border_size - padding)
      glEnd
      glEnable(GL_TEXTURE_2D)
    end

    glColor4f(1,1,1,1)
  end

  def size
    Font.select(font_options).sizeof(value)
  end

  def minimum_size; size end
  def maximum_size; size end
  def preferred_size; size end
end
