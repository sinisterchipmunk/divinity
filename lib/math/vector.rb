module Math
  # This is being phased out in favor of Geometry::Vector3d. I don't think this version
  # is actually being used by the engine right now. This file will be deleted eventually.
  class Vector
    attr_accessor :x, :y, :z
    
    def initialize(x=0,y=0,z=0); @x = x; @y = y; @z = z; end
    
    def sum; x + y + z; end
    def magnitude; Math.sqrt((self * self).sum); end
    def distance(a); (self - a).magnitude; end
    def distancev(a); self - a; end
    def collect; rx = yield x; ry = yield y; rz = yield z; Vector.new(rx,ry,rz); end
    def to_unit; self / magnitude; end
    def dot(a); self.x * a.x + self.y * a.y + self.z * a.z; end
    def angle(a); Math.acos(self.dot(a)); end
    def project_onto(a); a * self.dot(a.to_unit); end
      
    def orthogonal_with?(a); self.dot(a) == 0; end
    def cross(a)
      Vector.new(self.y*a.z-self.z*a.y,
                 self.z*a.x-self.x*a.z,
                 self.x*a.y-self.y*a.x)
    end
    
    
    def *(a); operate(a) { |b,c| b * c } end
    def /(a); operate(a) { |b,c| b / c } end
    def +(a); operate(a) { |b,c| b + c } end
    def -(a); operate(a) { |b,c| b - c } end
    
    def [](a)
      case a
        when 0, 'x', :x then x
        when 1, 'y', :y then y
        when 2, 'z', :z then z
        else raise "Array operand not supported: #{a}"
      end
    end
    
    private
    def operate(a)
      if a.is_a?(Vector)
        rx = yield self.x, a.x
        ry = yield self.y, a.y
        rz = yield self.z, a.z
      else
        rx = yield self.x, a
        ry = yield self.y, a
        rz = yield self.z, a
      end
      Vector.new(rx, ry, rz)
    end
  end
end