class Interface::Components::Button < Interface::Components::Component
  include Interface::Components::Button::InstanceMethods  

  def initialize(caption="Btn")
    super()
    init_variables(caption)
  end
  
  # Yay, everything else is in InstanceMethods: we're done here.
end
