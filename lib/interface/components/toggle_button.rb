class Interface::Components::ToggleButton < Interface::Components::InputComponent
  include Interface::Components::Button::InstanceMethods
  attr_reader :button_value

  def initialize(object, method, options = {}, &block)
    caption = options.delete(:caption) || method.to_s.titleize
    super(object, method, options)
    init_variables(caption)
    self.action_listeners << self

    yield if block_given?
  end

  def action_performed(evt)
    self.value = !self.value
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
