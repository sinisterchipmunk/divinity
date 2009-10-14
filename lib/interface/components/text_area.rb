# Note: This TextArea is not editable yet.
class Interface::Components::TextArea < Interface::Components::InputComponent
  include Listeners::KeyListener
  include Listeners::MouseListener
  theme_selection :text
  attr_reader :padding
  attr_accessor :caret_offset
  attr_reader :read_only, :scroll

  def scroll=(a)
    @scroll = a
    validate_scroll!
  end

  def scroll_down!
    @scroll -= font.height
    validate_scroll!
  end

  def scroll_up!
    @scroll += font.height
    validate_scroll!
  end

  def validate_scroll!
    min = printable_area.height - font.sizeof(@text_to_render).height
    @scroll = min if @scroll < min
    @scroll = 0 if @scroll > 0
  end

  def initialize(object, method, options = {}, &block)
    super(object, method, options, &block)
    @caret_offset = 0
    @padding = 2
    @read_only = true
    @text_to_render = value_changed
    @scroll = 0
    key_listeners << self
    mouse_listeners << self
  end

  def paint
    paint_background
    glTranslatef(printable_area.x, self.scroll + printable_area.y, 0)
    paint_text
    paint_caret
  end

  def paint_text
    # @text_to_render is already formatted for render, so just need to feed it into Font.put
    scissor printable_area do
      font.put 0, 0, @text_to_render
    end
  end

  def paint_caret
    return if read_only
    x, y = caret_position
    glColor4fv(foreground_color)
    glDisable(GL_TEXTURE_2D)
    glBegin(GL_LINES)
      glVertex2i(x, y)
      glVertex2i(x, y + Font.select.height)
    glEnd
    glEnable(GL_TEXTURE_2D)
  end

  def mouse_pressed(evt)
    # TODO: Make these constants somewhere. 4 is wheelup, 5 is wheeldown.
    if evt.button == 4 then scroll_up!
    elsif evt.button == 5 then scroll_down!
    end
  end

  def key_pressed(evt)
    case evt.sym
      when SDL::Key::UP    then scroll_up!
      when SDL::Key::DOWN  then scroll_down!
      when SDL::Key::LEFT  then move_caret -1
      when SDL::Key::RIGHT then move_caret 1
      when SDL::Key::ESCAPE
      when SDL::Key::BACKSPACE
        unless self.value.blank?
          #backspace!
          move_caret -1
        end
      when SDL::Key::HOME then move_caret -@caret_position
      when SDL::Key::END  then move_caret self.value.length - @caret_position
      when SDL::Key::RETURN
        self.value.insert(@caret_position, "\n") unless read_only
        move_caret 1
      else
        if evt.unicode != 0
          case evt.unicode
            when 0
            else
              self.value.insert(@caret_position, evt.unicode.chr) unless read_only
              move_caret 1
          end
        end
    end
  end

  def move_caret(amount)
    max = @text_to_render.join("").length
    @caret_offset += amount
    @caret_offset = max if @caret_offset > max
    @caret_offset = 0 if @caret_offset < 0
  end

  def value_changed
    @text_to_render = []
    self.value.split(/\n/).each do |line|
      if font.sizeof(line).width < printable_area.width
        @text_to_render << line
      else
        li = ""
        line.split(/\s/).each do |word|
          if font.sizeof("#{li} #{word}".strip).width >= printable_area.width
            @text_to_render << li.strip
            li = ""
          end
          li.concat " #{word}"
        end
        li.strip!
        @text_to_render << li unless li.blank?
      end
    end
    #invalidate # TODO: If display lists are used, component should probably be invalidated.
    @text_to_render
  end

  def validate
    super
    edge = (border_size + padding) * 2
    scroll_width = 0 # TODO: Scrollbars? Or should parent container take care of this?
    w = width - (edge + scroll_width)
    h = height - edge
    @printable_area = Rectangle.new border_size, border_size, w, h
  end

  def printable_area
    # just to keep things from breaking - the bounds are really set in #validate
    @printable_area ||= Rectangle.new
  end

  def preferred_size
    font.sizeof(@text_to_render)
  end

  def maximum_size
    Dimension.new(1024,1024)
  end

  def minimum_size
    Dimension.new(1,1)
  end
end
