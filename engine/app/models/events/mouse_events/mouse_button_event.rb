#SDL::Event2::MouseButtonDown#button - Returns the which button is pressed:
#                                      SDL::Mouse::BUTTON_LEFT
#                                      SDL::Mouse::BUTTON_MIDDLE
#                                      SDL::Mouse::BUTTON_RIGHT
#SDL::Event2::MouseButtonDown#press  - Returns true.
#SDL::Event2::MouseButtonDown#x      - Returns x of mouse cursor.
#SDL::Event2::MouseButtonDown#y      - Returns y of mouse cursor.
#    -or-
#SDL::Event2::MouseButtonUp#button - Returns the which button is released:
#                                    SDL::Mouse::BUTTON_LEFT
#                                    SDL::Mouse::BUTTON_MIDDLE
#                                    SDL::Mouse::BUTTON_RIGHT
#SDL::Event2::MouseButtonUp#press  - Returns false.
#SDL::Event2::MouseButtonUp#x      - Returns x of mouse cursor.
#SDL::Event2::MouseButtonUp#y      - Returns y of mouse cursor.
class Events::MouseEvents::MouseButtonEvent < Events::MouseEvents::MouseEvent
  delegate :x, :y, :to => :sdl_event
  attr_accessor :click_count
  private :click_count=

  def button
    case sdl_event.button
      when SDL::Mouse::BUTTON_LEFT   then :left
      when SDL::Mouse::BUTTON_MIDDLE then :middle
      when SDL::Mouse::BUTTON_RIGHT  then :right
      when 4 then :wheel_up
      when 5 then :wheel_down
      else raise "Mouse button not recognized: #{sdl_event.button}"
    end
  end

  def left?()   button == :left   end
  def right?()  button == :right  end
  def middle?() button == :middle end

  # Returns true if this button has been pressed, false if it has been released.
  def pressed?() sdl_event.press end
  def click?() @click_count > 0 end
end
