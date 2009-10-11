class Geometry::Rectangle
  attr_accessor :x, :y, :width, :height
  
  def initialize(x=0, y=0, w=0, h=0)
    @x = x
    @y = y
    @width = w
    @height = h
  end
end
