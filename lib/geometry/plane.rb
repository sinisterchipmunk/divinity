class Geometry::Plane
  attr_accessor :a, :b, :c, :d

  def initialize(a=0, b=0, c=0, d=0)
    self.a, self.b, self.c, self.d = a, b, c, d
  end
  
  def to_a
    [ a, b, c, d ]
  end

  def magnitude
    Math.sqrt(self.a ** 2 + self.b ** 2 + self.c ** 2)
  end

  def normalize!
    m = magnitude
    if m != 0
      self.a /= m
      self.b /= m
      self.c /= m
      self.d /= m
    end
    self
  end
end
