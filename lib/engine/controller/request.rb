class Engine::Controller::Request
  attr_reader :args, :options, :block, :engine
  attr_accessor :bounds
  delegate :width, :height, :to => :bounds

  def initialize(engine, bounds, *args, &block)
    @engine = engine
    @options = args.extract_options!
    @args = args
    @block = block if block_given?
    @bounds = bounds.dup
  end

  def center
    Geometry::Point.new(width / 2, height / 2)
  end
  
  def parameters
    options
  end
end
