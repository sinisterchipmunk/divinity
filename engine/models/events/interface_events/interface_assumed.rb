class Events::InterfaceEvents::InterfaceAssumed
  attr_reader :previous_controller, :previous_action, :new_controller, :new_action
  
  def initialize(previous_controller, previous_action, new_controller, new_action)
    @previous_controller, @previous_action, @new_controller, @new_action =
            previous_controller, previous_action, new_controller, new_action
  end
end