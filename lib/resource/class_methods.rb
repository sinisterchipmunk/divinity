module Resource::ClassMethods
  def find(id)
    return resource_map[id] if resource_map.key? id
    raise Errors::ResourceNotFound, "Could not find resource #{self.name}:#{id}"
  end

  def add(instance)
    resource_map[instance.id] = instance
    instance
  end
  alias update add

  def all
    resource_map.collect { |i| i[1] } # return an array, not a hash
  end

  def resource_map
    @resources ||= HashWithIndifferentAccess.new
  end
end
  