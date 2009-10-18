class Interface::Components::ToggleButton < Interface::Components::InputComponent
  include Interface::Components::Button::InstanceMethods
  attr_reader :button_value

  def after_initialize(options)
    caption = (options.delete(:caption) || self.send(:method) || self.value).to_s.titleize
    init_variables(caption)
    on :action_performed do self.value = !self.value end
    set_options! options
  end

  def update(delta)
    if value
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
