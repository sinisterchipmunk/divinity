class Resources::Content
  include Helpers::AttributeHelper
  attr_reader :engine
  random_access_attr :id, :name, :description

  def initialize(id, engine, &block)
    @id = id
    @engine = engine

    name @id.to_s.titleize
    description "No description."

    revert_to_defaults!
    yield_with_or_without_scope(&block) if block_given?
  end

  def revert_to_defaults!
  end
end