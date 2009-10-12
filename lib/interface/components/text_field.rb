class Interface::Components::TextField < Interface::Components::InputComponent
  theme_selection :text
  attr_reader :font_options, :padding
  attr_accessor :color
  attr_accessor :caret_position

  include Listeners::KeyListener

  def initialize(object, method, options = {}, &block)
    @color = [ 0, 0, 0, 1 ]
    @font_options = {}
    @caret_position = 0
    @padding = 4
    super(object, method, options)

    key_listeners << self

    yield if block_given?
  end
  
  def key_pressed(evt)
    case evt.sym
      when SDL::Key::UP
      when SDL::Key::DOWN
      when SDL::Key::LEFT
        @caret_position -= 1
        @caret_position = 0 if @caret_position < 0
      when SDL::Key::RIGHT
        @caret_position += 1
        @caret_position = self.value.length if @caret_position > self.value.length
      when SDL::Key::ESCAPE
      when SDL::Key::BACKSPACE
        unless self.value.blank?
          self.value = self.value[0...(@caret_position-1)] + self.value[@caret_position..-1]
          @caret_position -= 1
        end
      when SDL::Key::HOME
        @caret_position = 0
      when SDL::Key::END
        @caret_position = self.value.length
      when SDL::Key::RETURN
        # No enter key accepted here
      else
        if evt.unicode != 0
          case evt.unicode
            when 0
            else
              self.value.insert(@caret_position, evt.unicode.chr)
              @caret_position += 1
          end
        end
    end
  end

  def paint
    self.value = self.value.to_s unless self.value.kind_of? String
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
    self.value = self.value.to_s unless self.value.kind_of? String
    Font.select(font_options).sizeof(value)
  end

  def minimum_size; size end
  def maximum_size; size end
  def preferred_size; size end
end
