module Events
  include Events::MouseEvents
  include Events::KeyboardEvents
  include Events::InterfaceEvents

  def self.sdl_to_divinity(event)
    if event.kind_of? SDL::MouseButtonEvent
      if event.type == SDL::MOUSEBUTTONDOWN
        Events::MousePressed.new(event)
      else
        Events::MouseReleased.new(event)
      end
    elsif event.kind_of? SDL::MouseMotionEvent then Events::MouseMoved.new(event)
    elsif event.kind_of? SDL::KeyboardEvent
      if event.type == SDL::KEYDOWN
        Events::KeyPressed.new(event)
      else
        Events::KeyReleased.new(event)
      end
    else raise Errors::EventNotRecognized, "event not recognized: #{event.inspect}"
    end
  end
end
