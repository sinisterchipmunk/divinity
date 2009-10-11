module Listeners::Mouse::ButtonMouseListener
  DOWN_SHADE = 0.8
  NORM_SHADE = 1
  OVER_SHADE = 1.25

  def mouse_pressed(evt)
    background_texture.set_option :brightness, DOWN_SHADE
    @state |= Interface::Components::Button::ButtonState::MOUSE_DOWN
  end
  
  def mouse_released(evt)
    if @state & Interface::Components::Button::ButtonState::MOUSE_OVER > 0
      background_texture.set_option :brightness, OVER_SHADE
    else background_texture.set_option :brightness, NORM_SHADE
    end
    @state ^= Interface::Components::Button::ButtonState::MOUSE_DOWN
    action_listeners.each do |al|
      al.action_performed(evt)
    end
  end

  def mouse_entered(evt)
    if @state & Interface::Components::Button::ButtonState::MOUSE_DOWN > 0
      background_texture.set_option :brightness, DOWN_SHADE
    else background_texture.set_option :brightness, OVER_SHADE
    end
    @state |= Interface::Components::Button::ButtonState::MOUSE_OVER
  end

  def mouse_exited(evt)
    background_texture.set_option :brightness, NORM_SHADE
    @state ^= Interface::Components::Button::ButtonState::MOUSE_OVER
  end
  
  def mouse_moved(evt);    end
  def mouse_dragged(evt);  end
end
