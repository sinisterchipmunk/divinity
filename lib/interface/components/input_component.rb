class Interface::Components::InputComponent < Interface::Components::Component
  include Helpers::AttributeHelper
  attr_accessor :object
  attr_accessor :method, :delimeter 

  def initialize(object_or_value, method = nil, options = {}, &block)
    super()
    @object, @method = object_or_value, method
    @last_value = nil
    @delimeter = options.delete(:delimeter) || "."

    v = options.delete :value
    self.value = v if v

    after_initialize(options) if self.respond_to? :after_initialize
    yield_with_or_without_scope(&block) if block_given?
  end

  def set_options!(options)
    options.each { |key, value| self.send("#{key}=", value) }
    self
  end

  def value
    if method
      if object.respond_to? method
        object.send(method)
      else
        # FIXME: is there a better way to accomplish this same thing? Eval isn't exactly the fastest method in the world.
        eval "self.object#{delimeter}#{method}", binding, __FILE__, __LINE__
      end
    else
      object.to_s
    end
  end

  def value=(a)
    if method
      if object.respond_to? "#{method}="
        object.send("#{method}=", a)
      else
        # FIXME: is there a better way to accomplish this same thing? Eval isn't exactly the fastest method in the world.
        eval "self.object#{delimeter}#{method} = a", binding, __FILE__, __LINE__
      end
    else
      self.object = a
    end
  end

  def update(delta)
    super
    if self.value != @last_value # value has changed, update the object
      @last_value = self.value
      fire_event :value_changed
    end
  end
end
