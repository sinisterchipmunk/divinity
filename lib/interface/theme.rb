class Interface::Theme < Resources::Content
  attr_reader :options

  def set(type, options)
    self.select(type).merge! options
  end

  def initialize(id = nil, engine = nil, &block)
    @options = HashWithIndifferentAccess.new
    super(id, engine, &block)
  end

  def select(type = :default, defaults = (@options[:default] || HashWithIndifferentAccess.new))
    @options[type] ||= HashWithIndifferentAccess.new
    @options[type].reverse_merge!(defaults)
  end
end
