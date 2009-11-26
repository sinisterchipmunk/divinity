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
class Components::ButtonController < Components::ComponentController
  #dump_events # causes all events sent to this component to be dumped to stdout
  redirect :mouse_released, :mouse_exited, :to => :button_released
  redirect :mouse_pressed, :to => :button_pressed
  #model :button # this should be automated for models that share a name with the controller. Also, the model object
                # is assigned to both self.model and self.[name].

  def index
  end
  
  def button_pressed
    button.state = :pressed
    render :action => :index
  end

  def button_released
    button.state = :released
    
    # When an event is fired, we should expect the standard event functionality (via #on), but additionally,
    # the parent controller should receive the event automatically as an action. If the parent doesn't respond
    # to the event, then it is sent to the parent's parent, and so on until something responds or the root element
    # has been reached. If nothing receives the event, it should fail silently because it's apparently a nonessential
    # result.
    fire_event :button_clicked if mouse.over?
    
    render :action => :index
  end
end
