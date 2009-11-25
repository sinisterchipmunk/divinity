class Events::InputEvent
  attr_reader :sdl_event
  
  def initialize(sdl_event)
    @sdl_event = sdl_event
  end
end
