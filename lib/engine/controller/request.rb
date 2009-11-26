class Engine::Controller::Request
  attr_reader :args, :options, :block, :engine
  attr_accessor :bounds, :controller
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

  # Converts the given screen coordinates into local space, using the root element's bounds as the origin.
  def translate_absolute(x, y)
    if controller.parent
      x, y = *controller.parent.translate_absolute(x, y)
    end
    translate(x, y)
  end

  # Converts the given coordinates into local space; that is, uses bounds.x and bounds.y for the origin.
  def translate(x, y)
    [ x - bounds.x, y - bounds.y ]
  end

  # Returns true if the specified point is contained within the bounds of this request.
  # X and Y are expected to be within this component's local space (that is, an X coordinate of 0 references
  # the top-left corner of this component, regardless of the value of bounds.x).
  # Use #translate to translate a point into local space.
  def contains?(x, y)
#    puts x, y
#    puts bounds.width, bounds.height
#    puts
    
    x < bounds.width && y < bounds.height
  end
end
