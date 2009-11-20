class Engine::Controller::Events::FocusEvent
  def initialize(lost, gained)
    @lost, @gained = lost, gained
  end
end
