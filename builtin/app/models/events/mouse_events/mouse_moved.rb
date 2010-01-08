#SDL::Event2::MouseMotion#state - Returns the button state.
#SDL::Event2::MouseMotion#x     - Returns x of mouse cursor.
#SDL::Event2::MouseMotion#y     - Returns y of mouse cursor.
#SDL::Event2::MouseMotion#xrel  - Returns relative x coordinates.
#SDL::Event2::MouseMotion#yrel  - Returns relative y coordinates.
class Events::MouseEvents::MouseMoved < Events::MouseEvents::MouseEvent
  delegate :state, :x, :y, :xrel, :yrel, :to => :sdl_event

  alias relative_x xrel
  alias relative_y yrel

  def pressed?(button = :any)
    case button
      when :any then pressed?(:left) || pressed?(:middle) || pressed?(:right)
      when :left,   SDL::BUTTON_LEFT   then state & SDL::BUTTON_LEFT   > 0
      when :middle, SDL::BUTTON_MIDDLE then state & SDL::BUTTON_MIDDLE > 0
      when :right,  SDL::BUTTON_RIGHT  then state & SDL::BUTTON_RIGHT  > 0
      else raise "Expected button to be :left, :middle, :right or :any. Found #{button.inspect}"
    end
  end

  # It's conceptually different, but programmatically the same.
  alias dragged? pressed?
end
