class Engine::Controller::Request
  attr_reader :args, :options, :block
  attr_accessor :bounds
  delegate :width, :height, :to => :bounds

  def initialize(bounds, *args, &block)
    @options = args.extract_options!
    @args = args
    @block = block if block_given?
    @bounds = bounds.dup
  end
  
  def parameters
    options
  end
end
