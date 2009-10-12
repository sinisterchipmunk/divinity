class Interface::Theme
  include Helpers::AttributeHelper
  random_access_attr :id, :name
  attr_reader :options

  def set(type, options)
    self.select(type).merge! options
  end

  def initialize(id = nil, &block)
    @id = id
    @name = id.to_s.titleize
    @options = HashWithIndifferentAccess.new

    yield_with_or_without_scope(&block) if block_given?
  end

  def select(type = :default, defaults = (@options[:default] || HashWithIndifferentAccess.new))
    @options[type] ||= HashWithIndifferentAccess.new
    @options[type].reverse_merge!(defaults)
  end
end
