class Interface::Components::RadioButton < Interface::Components::InputComponent
  include Interface::Components::Button::InstanceMethods
  attr_reader :button_value

  def after_initialize(options)
    @button_value = options.delete(:value) || self.value
    init_variables((options.delete(:caption) || self.value).to_s.titleize)
    on :action_performed do self.value = button_value end
    set_options! options
  end

  def update(delta)
    if value == button_value
      background_texture.set_option :brightness, DOWN_SHADE
      @state = BUTTON_DOWN
    else
      @state = BUTTON_UP
      option = NORM_SHADE
      option = OVER_SHADE if @mouse_state & MOUSE_OVER > 0
      if @mouse_state & MOUSE_DOWN > 0
        option = DOWN_SHADE
        @state = BUTTON_DOWN
      end
      background_texture.set_option :brightness, option
    end
    super
  end
end
