# This module is mixed into DivinityEngine and is responsible for providing a way to interface with the various
# controllers. It is initially called from Engine::ContentLoader.
#
module Engine::Controller::Routing
  def assume_interface(id, *args)
    id = id.to_s if id.kind_of? Symbol
    if id.kind_of? String
      id = id.camelize
      id = "#{id.camelize}Controller" unless id.ends_with?("Controller")
      id = id.constantize
    end
    
    # by now, id should be a type of Controller. If we have a running instance of id, we should switch over to it.
    # If not, we should construct request and response objects and instantiate the controller.
    @instantiated_controllers ||= Hash.new
    cur = self.current_controller
    instance = nil
    if @instantiated_controllers[id]
      instance = @instantiated_controllers[id]
    else
      request = Engine::Controller::Request.new(*args)
      instance = @instantiated_controllers[id] = id.new(self, request)
      instance.response.bounds = [0, 0, width, height]
      instance.process(:index, Engine::Controller::Events::ControllerCreatedEvent.new(instance))
    end

    # Dispatch a focus event to both controllers
    evt = Engine::Controller::Events::FocusEvent.new(cur, instance)
    cur.process_event(:focus_lost, evt) if cur
    instance.process_event(:focus_gained, evt)
    self.current_controller = instance
  end
end
