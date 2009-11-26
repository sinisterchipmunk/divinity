class Engine::Controller::MouseProxy < Engine::Controller::InputDeviceProxy
  # state methods
  delegate :x, :y, :pressed?, :to => :device

  # device methods
  delegate :state, :warp_to!, :show!, :hide!, :cursor=, :cursor, :respond_to_event?, :process_event,
           :to => :device

  # Returns true if the mouse is currently over the controller's component object, false or nil otherwise.
  def over?
    if controller.contains?(*controller.translate_absolute(x, y))
      # the event occurred within this component's local space
      @over = true
    end
  end
end
