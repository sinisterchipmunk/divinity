class Interface::Theme < Resources::Content
  class ThemeType < HashWithIndifferentAccess
    def apply_to(image, draw)
      raise unless image
      self.each do |key, value|
        puts "#{key} => #{value}"
      end
      puts
    end
  end

  attr_reader :options

  def set(type, options)
    self.select(type).merge! options
  end

  def initialize(id = nil, engine = nil, &block)
    @options = Hash.new
    super(id, engine, &block)
  end

  def select(type = :default, defaults = (@options[:default] || ThemeType.new))
    type = type.to_s unless type.kind_of? String
    @options[type] = ThemeType.new if @options[type].nil?
    @options[type].reverse_merge!(defaults)
  end

  def with_args(options)
    raise ArgumentError, "Expected a hash, got a #{options.class}" unless options.kind_of? Hash
    raise ArgumentError, "Expected hash to contain :type" unless options.keys.include? :type
    select(options.delete(:type), options)
  end
end
