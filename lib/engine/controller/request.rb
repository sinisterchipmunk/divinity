class Engine::Controller::Request
  attr_reader :args, :options, :block

  def initialize(*args, &block)
    @options = args.extract_options!
    @args = args
    @block = block
  end
  
  def parameters
    options
  end
end
