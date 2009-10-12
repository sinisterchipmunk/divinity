class Geometry::Rectangle
  attr_accessor :x, :y, :width, :height
  
  def initialize(x=0, y=0, w=0, h=0)
    @x = x
    @y = y
    @width = w
    @height = h
  end

  def union(rect)
    Rectangle.new(@x, @y, @width, @height).union! rect
  end

  def union!(r)
    tx2 = width
    ty2 = height
    return r if ((tx2 | ty2) < 0)
    rx2 = r.width
    ry2 = r.height
    return self if ((rx2 | ry2) < 0)
    tx1, ty1 = x, y
    tx2 += tx1
    ty2 += ty1
    rx1, ry1 = r.x, r.y
    rx2 += rx1
    ry2 += ry1
    tx1 = rx1 if tx1 > rx1
    ty1 = ry1 if ty1 > ry1
    tx2 = rx2 if tx2 < rx2
    ty2 = ry2 if ty2 < ry2
    tx2 -= tx1
    ty2 -= ty1

    @x, @y, @width, @height = tx1, ty1, tx2, ty2
    self
  end
end
