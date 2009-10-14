class Geometry::Dimension
  attr_accessor :width, :height
  
  def initialize(w=0,h=0)
    @width = w
    @height = h
  end

  def to_a
    [width, height]
  end
end
