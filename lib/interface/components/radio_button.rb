class Interface::Components::RadioButton < Interface::Components::InputComponent
  include Interface::Components::Button::InstanceMethods
  attr_reader :button_value

  def initialize(object, method, value, options = {}, &block)
    if value.kind_of? Hash
      options.merge! value
      value = options.delete :value
    end
    @button_value = value
    
    super(object, method, options)
    caption = options[:caption] || value.to_s.titleize
    init_variables(caption)
    yield if block_given?
  end

  def button_value=(a)
    self.value = a if self.value == @button_value
    @button_value = a
    invalidate  # FIXME: Not sure why I'm doing this, but it feels right. Need to see if it's really necessary.
    a
  end

  def action_performed(evt)
    puts 'performed'
    self.value = button_value
  end

  def update(delta)
    if value == button_value
      background_texture.set_option :brightness, DOWN_SHADE
      @state = BUTTON_DOWN
    else
      update_state
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
