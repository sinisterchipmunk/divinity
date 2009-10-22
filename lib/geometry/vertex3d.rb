class Geometry::Vertex3d
  attr_accessor :x, :y, :z, :w

  def initialize(*args)
    if args.length == 1
      @x, @y, @z, @w = args[1].to_a
    else
      @x, @y, @z, @w = args
    end
  end

  def magnitude; Math.sqrt x*x + y*y + z*z; end
  def distance(v) Math.sqrt(((v.x-x) ** 2) + ((v.y-y) ** 2 ) + ((v.z-z) ** 2)) end
  alias distance_from distance

  def scale!(*amount)
    x, y, z = if amount[0].kind_of? Array then amount
    elsif amount[0].kind_of? Vertex3d then amount[0].to_a
    elsif amount.length == 3 then amount
    else [amount, amount, amount]
    end

    self.x, self.y, self.z = self.x*x, self.y*y, self.z*z
    self
  end

  def dot(v)
    x * v.x + y * v.y + z * v.z
  end

  def normalize!
    mag = magnitude
    return self if mag == 0
    self.x, self.y, self.z = self.x / mag, self.y / mag, self.z / mag
    self
  end

  def scale(*amount)
    self.dup.scale! *amount
  end

  # Converts self into a vector that is perpendicular to to both A (this) and B (v) and then returns self.
  # A x B = <Ay*Bz - Az*By, Az*Bx - Ax*Bz, Ax*By - Ay*Bx>
  def cross!(v)
    self.x, self.y, self.z = y * v.z - z * v.y, z * v.x - x * v.z, x * v.y - y * v.x
    self
  end

  def normalize
    self.dup.normalize!
  end

  def cross(v)
    self.dup.cross! v
  end

  def -@
    self.class.new(-x, -y, -z)
  end

  ["+", "-", "*", "/", "**"].each do |op|
    line = __LINE__ + 2
    code = <<-end_code
      def #{op}(*args)
        a, b, c = if args.length == 1
          if args[0].kind_of? Array then args[0]
          elsif args[0].kind_of? Vertex3d then args[0].to_a
          else [args[0], args[0], args[0]]
          end
        else args
        end
        self.class.new(@x #{op} a, @y #{op} b, @z #{op} c)
      end     
    end_code
    eval code, binding, __FILE__, line
  end

  def to_a
    if w then [ x, y, z, w ]
    else [ x, y, z ]
    end
  end
end
