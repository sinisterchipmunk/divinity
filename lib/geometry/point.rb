class Geometry::Point
  attr_accessor :x, :y
  
  def initialize(x=0, y=0)
    @x = x
    @y = y
  end

  def to_a
    [x,y]
  end
end