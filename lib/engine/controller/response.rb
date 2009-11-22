class Engine::Controller::Response
  class Insets
    attr_accessor :top_left, :bottom_right

    def initialize(x1, y1, x2, y2)
      @top_left = Geometry::Point.new(x1, y1)
      @bottom_right = Geometry::Point.new(x2, y2)
    end

    def tlx; top_left.x; end
    def tly; top_left.y; end
    def brx; bottom_right.x; end
    def bry; bottom_right.y; end
  end

  attr_accessor :insets, :preferred_size, :minimum_size, :maximum_size, :request, :view, :redirected_to
  attr_reader :graphics_context
  delegate :bounds, :width, :height, :to => :request

  def initialize()
    @_completed = false
    @preferred_size = Geometry::Dimension.new(64, 64)
    @minimum_size = Geometry::Dimension.new(1, 1)
    @maximum_size = Geometry::Dimension.new(1024, 1024)
    @insets = Insets.new(0, 0, 0, 0)
  end

  def completed?
    @_completed
  end

  def process
    prepare_graphics_context!
    view.process
    @_completed = true
  end

  def prepare_graphics_context!
    if @image then @image.resize!(bounds.width, bounds.height)
    else @image = Magick::Image.new(bounds.width, bounds.height)
    end
    @image.erase!
  end
end
