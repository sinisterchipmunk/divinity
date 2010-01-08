#SDL::Event2::KeyDown
#    This event occurs when a key is pressed.
#
#    SDL::Event2::KeyDown#press   - Returns true.
#    SDL::Event2::KeyDown#sym     - Returns the pressed key such as SDL::Key::ESCAPE.
#    SDL::Event2::KeyDown#mod     - Same as SDL::Key.modState.
#    SDL::Event2::KeyDown#unicode - Returns key input translated to UNICODE.
#                                   If you will use this, you need to call SDL::Event2.enableUNICODE beforehand.
#
#
#SDL::Event2::KeyUp
#    This event occurs when a key is released.
#
#    SDL::Event2::KeyUp#press - Returns false.
#    SDL::Event2::KeyUp#sym   - Returns the released key such as SDL::Key::ESCAPE.
#    SDL::Event2::KeyUp#mod   - Same as SDL::Key.modState.
class Events::KeyboardEvents::KeyEvent < Events::InputEvent
  include Devices::Keyboard::Modifiers

  delegate :type, :which, :state, :window_id, :to => :sdl_event
  delegate :sym, :mod, :to => :key

  def key; @key ||= Devices::Keyboard::Key.new(sdl_event.keysym) end
  alias keysym key

  def device_type; :keyboard end
  def pressed?() (state == SDL_PRESSED) end
  def name() SDL::GetKeyName(sym) end
  def modifiers() array_of_modifiers(mod) end
end
