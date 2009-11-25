module Events
  include Events::MouseEvents
  include Events::KeyboardEvents
  include Events::InterfaceEvents

  def self.sdl_to_divinity(event)
    if event.kind_of? SDL::Event::MouseButtonDown  then Events::MousePressed.new(event)
    elsif event.kind_of? SDL::Event::MouseButtonUp then Events::MouseReleased.new(event)
    elsif event.kind_of? SDL::Event::MouseMotion   then Events::MouseMoved.new(event)
    elsif event.kind_of? SDL::Event::KeyDown       then Events::KeyPressed.new(event)
    elsif event.kind_of? SDL::Event::KeyUp         then Events::KeyReleased.new(event)
    else raise Errors::EventNotRecognized, "event not recognized: #{event.inspect}"
    end
  end
end
