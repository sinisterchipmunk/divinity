## Concept

# events are mapped to their respective actions automatically. this includes:
#
#   mouse_pressed, mouse_released, mouse_entered, mouse_exited, mouse_clicked, mouse_dragged, mouse_moved
#   key_pressed, key_released, key_typed
#   joystick events (not yet defined)
#
# because some events will have the same result, they can be grouped together using #redirect:
#   redirect :mouse_released, :mouse_exited, :to => :button_released
#
# event structures are maintained automatically, and are updated before any actions are called. They can be accessed
# by name:
#   keyboard
#   mouse
#   joysticks[]
#
# Per Rails convention, ButtonController should actually extend a ComponentController (or some such) which in turn
# extends Engine::Controller::Base. That way helpers, filters, etc. can be specified at the Component level.
#
class ButtonController < ComponentController
  redirect :mouse_released, :mouse_exited, :to => :button_released
  redirect :mouse_pressed, :to => :button_pressed
  model :button # this should be automated for models that share a name with the controller. Also, the model object
                # is assigned to both self.model and self.[name].

  def index
  end
  
  def button_pressed
    button.state = :pressed
    render :action => :index
  end

  def button_released
    button.state = :released
    fire_event :button_clicked if mouse.over?
    render :action => :index
  end
end
