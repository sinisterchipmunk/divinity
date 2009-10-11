module Engine::DefaultUpdateBlock
  def add_default_update_block
    during_update do |ticks, engine|
      while event = SDL::Event2.poll
        case event
          when SDL::Event::Quit then stop!
          when SDL::Event::MouseButtonDown, SDL::Event::MouseButtonUp, SDL::Event::MouseMotion
            frame_manager.process_mouse_event(event)
          when SDL::Event::KeyDown, SDL::Event::KeyUp then frame_manager.process_key_event(event)
        end
      end

      engine.frame_manager.update(ticks)
    end
  end
end