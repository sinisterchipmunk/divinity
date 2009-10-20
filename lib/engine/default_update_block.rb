module Engine::DefaultUpdateBlock
  def add_default_update_block
    before_update do |ticks, engine|
      while event = SDL::Event2.poll
        case event
          when SDL::Event::Quit then stop!
          when SDL::Event::MouseButtonDown, SDL::Event::MouseButtonUp, SDL::Event::MouseMotion
            frame_manager.process_mouse_event(event)
            fire_event :mouse_pressed,  event if event.kind_of? SDL::Event::MouseButtonDown and @state != :paused
            fire_event :mouse_released, event if event.kind_of? SDL::Event::MouseButtonUp and @state != :paused
            fire_event :mouse_moved,    event if event.kind_of? SDL::Event::MouseMotion and @state != :paused
          when SDL::Event::KeyDown, SDL::Event::KeyUp then frame_manager.process_key_event(event)
            fire_event :key_pressed,    event if event.kind_of? SDL::Event::KeyDown and @state != :paused
            fire_event :key_released,   event if event.kind_of? SDL::Event::KeyUp and @state != :paused
        end
      end

      frame_manager.update(ticks)
    end
  end
end