class Engine::Controller::Events::ControllerCreatedEvent
  def initialize(instance, parent = nil)
    @instance = instance
    @parent = parent
  end
end
