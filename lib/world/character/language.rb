class World::Character::Language
  include Helpers::AttributeHelper
  random_access_attr :id, :name, :alphabet, :description, :secret

  def initialize(id, &block)
    @id = id
    name id.to_s.titleize
    alphabet id
    description "No Description"
    secret false

    yield_with_or_without_scope(&block) if block_given?
  end

  def secret?
    @secret
  end
end
