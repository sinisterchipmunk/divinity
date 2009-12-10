class Events::KeyboardEvents::KeyPressed < Events::KeyboardEvents::KeyEvent
  delegate :unicode, :to => :sdl_event
end
