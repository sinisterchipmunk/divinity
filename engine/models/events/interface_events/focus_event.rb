class Events::InterfaceEvents::FocusEvent
  attr_reader :lost, :gained
  
  def initialize(lost, gained)
    @lost, @gained = lost, gained
  end
end
