class Events::InterfaceEvents::Redirected
  attr_reader :previous_controller, :previous_action, :new_controller, :new_action
  def initialize(prev_controller, prev_action, new_controller, new_action)
    @previous_controller, @previous_action, @new_controller, @new_action =
            prev_controller, prev_action, new_controller, new_action
  end
end
