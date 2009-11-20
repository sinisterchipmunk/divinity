class Object
  def define_singleton_method(name, &block)
    # Get a handle to the singleton class of obj
    metaclass = class << obj; self; end 
    metaclass.send :define_method, name, &block
  end
end