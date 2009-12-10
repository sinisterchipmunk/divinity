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

  delegate :sym, :mod, :to => :sdl_event

  def device_type; :keyboard end
  def pressed?() sdl_event.press end
  def name() SDL::Key.get_key_name(sym) end
  def modifiers() array_of_modifiers(sdl_event.mod) end
end
