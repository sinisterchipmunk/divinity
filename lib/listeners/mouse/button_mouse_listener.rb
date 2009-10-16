module Listeners::Mouse::ButtonMouseListener
  # Texture definitions
  DOWN_SHADE = 0.8
  NORM_SHADE = 1
  OVER_SHADE = 1.25

  # Mouse states
  MOUSE_DOWN = 1
  MOUSE_OVER = 2

  # Button states
  # These are tied directly into InstanceMethods#paint so be careful when changing.
  BUTTON_UP = 0
  BUTTON_DOWN = 1

  def update_state
    @state = ((@mouse_state & MOUSE_DOWN > 0 and @mouse_state & MOUSE_OVER > 0) ? BUTTON_DOWN : BUTTON_UP)
  end

  def mouse_pressed(evt)
    background_texture.set_option :brightness, DOWN_SHADE
    @mouse_state |= MOUSE_DOWN
    update_state
  end
  
  def mouse_released(evt)
    if @mouse_state & MOUSE_OVER > 0
      background_texture.set_option :brightness, OVER_SHADE
      fire_event :action_performed, evt
    else background_texture.set_option :brightness, NORM_SHADE
    end
    @mouse_state ^= MOUSE_DOWN
    update_state
  end

  def mouse_entered(evt)
    if @mouse_state & MOUSE_DOWN > 0
      background_texture.set_option :brightness, DOWN_SHADE
    else background_texture.set_option :brightness, OVER_SHADE
    end
    @mouse_state |= MOUSE_OVER
    update_state
  end

  def mouse_exited(evt)
    background_texture.set_option :brightness, NORM_SHADE
    @mouse_state ^= MOUSE_OVER
    update_state
  end
  
  def mouse_moved(evt)
    @mouse_state |= MOUSE_OVER
  end

  def mouse_dragged(evt)
    @mouse_state |= MOUSE_OVER
    @mouse_state |= MOUSE_DOWN
  end
end
