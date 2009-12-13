class Events::InterfaceEvents::ControllerCreatedEvent
  def initialize(instance, parent = nil)
    @instance = instance
    @parent = parent
  end
end
