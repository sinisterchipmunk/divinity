class Interface::Components::InputComponent < Interface::Components::Component
  attr_accessor :target
  attr_accessor :method

  def initialize(target, method, options = {})
    super()
    @target, @method = target, method
    @last_value = nil
    @value = options[:value]
    @value ||= target.send("#{method}") if target and method
  end

  def value
    if target and method
      target.send(method)
    else
      @value
    end
  end

  def value=(a)
    if target and method
      target.send("#{method}=", a)
    else
      @value = a
    end
  end

  def update(delta)
    super
#    if self.value != @last_value # value has changed, update the target
#      target.send("#{method}=", self.value)
#      @last_value = self.value
#    end
  end
end
