class Engine::Controller::InputDeviceProxy
  attr_reader :controller, :device
  delegate :engine, :to => :controller

  def initialize(controller, device)
    @controller, @device = controller, device
  end
end
