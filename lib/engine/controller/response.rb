class Engine::Controller::Response
  attr_accessor :bounds

  def initialize
    @_completed = false
    @bounds = nil
  end

  def completed?
    @_completed
  end

  def process(controller, view)
    view.process(controller)
    @_completed = true
  end
end
