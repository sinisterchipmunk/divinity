class Interface::Theme::Effects::Effect
  attr_reader :args

  class << self
    # Specifies that argument number "num" must be of type "klass".
    def arg(num, klass) args({num => klass}) end

    # Takes a hash which maps argument number to class type. Returns the map of argument types.
    def args(map = nil)
      @args ||= {}
      @args.merge! map if map
      @args
    end

    # Specifies the number of arguments, or a range. If the upper value is -1, there is no maximum.
    # If the lower value is less than 1, there is no minimum.
    def num_args(num = nil)
      @num_args = num if num
      @num_args
    end
  end

  def initialize(*args)
    @args = args
    validate_args
  end

  def apply_to(image)
    apply(image, *args)
  end

  def validate_args
    map = self.class.args
    range = self.class.num_args

    if range.kind_of?(Numeric) && range > -1 && args.length != range
      raise ArgumentError, "wrong number of arguments (#{args.length} for #{range})"
    else
      lower, upper = range.first, range.last
      if lower > args.length || (upper > -1 && upper < args.length)
        message = "wrong number of arguments (#{args.length} for #{lower}"
        if upper < 0
          message.concat "+"
        else
          message.concat "..#{upper}"
        end
        message.concat ")"
        raise ArgumentError, message
      end
    end

    map.each do |num, type|
      unless args[num].nil? or args[num].kind_of?(type)
        raise "invalid type: expected #{type.name}, found #{args[num].inspect}"
      end
    end
  end
end
