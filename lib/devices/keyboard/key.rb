# Wrapper around SDL::Keysym
class Devices::Keyboard::Key
  attr_reader :sdl_keysym

  delegate :scancode, :sym, :mod, :unicode, :to => :sdl_keysym

  
end
