class Resource::Base
  extend Resource::ClassMethods
  include Helpers::AttributeHelper
  attr_reader :engine
  random_access_attr :id, :name, :description

  def initialize(id, &block)
    @id = id
    #@engine = engine

    name @id.to_s.titleize
    description "No description."

    revert_to_defaults!
    yield_with_or_without_scope(&block) if block_given?
  end

  def revert_to_defaults!
  end

#  def respond_to?(*args, &block)
#    super or engine.respond_to? *args, &block
#  end
#
#  def method_missing(*args, &block)
#    engine.respond_to?(args[0]) ? engine.send(*args, &block) : super
#  end
end
