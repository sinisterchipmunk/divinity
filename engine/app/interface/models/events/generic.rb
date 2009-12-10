class Events::Generic
  attr_reader :name, :model, :args
  
  def initialize(name, model, *args)
    @name = name
    @model = model
    @args = args
  end
end
