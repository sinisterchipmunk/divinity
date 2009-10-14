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
    tx2 = width.to_i
    ty2 = height.to_i
    return r if ((tx2 | ty2) < 0)
    rx2 = r.width.to_i
    ry2 = r.height.to_i
    return self if ((rx2 | ry2) < 0)
    tx1, ty1 = x.to_i, y.to_i
    tx2 += tx1
    ty2 += ty1
    rx1, ry1 = r.x.to_i, r.y.to_i
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
