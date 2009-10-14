class Interface::Components::InputComponent < Interface::Components::Component
  attr_accessor :target
  attr_accessor :method, :delimeter 

  def initialize(target, method, options = {})
    super()
    @target, @method = target, method
    @last_value = nil
    @delimeter = options[:delimeter] || "."
    @value = options[:value]
    @value ||= self.value #target.send("#{method}") if target and method
  end

  def value
    if target and method
      if target.respond_to? method
        target.send(method)
      else
        eval "target#{delimeter}#{method}", binding, __FILE__, __LINE__
      end
    else
      nil
    end
  end

  def value=(a)
    if target.respond_to? "#{method}="
      target.send("#{method}=", a)
    else
      eval "target#{delimeter}#{method} = a", binding, __FILE__, __LINE__
    end
  end

  def update(delta)
    super
    if self.value != @last_value # value has changed, update the target
      @last_value = self.value
      self.value_changed if self.respond_to? :value_changed
    end
  end
end
