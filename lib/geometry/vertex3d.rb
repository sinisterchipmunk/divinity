# Represents a single point in 3D space.
class Geometry::Vertex3d
  attr_accessor :x, :y, :z

  # A Vertex3d object can be initialized in any of the following ways:
  #
  #  Vertex3d.new(0, 1, 2)  # => x: 0, y: 1, z: 2
  #  Vertex3d.new [0, 1, 2) # => x: 0, y: 1, z: 2
  #  Vertex3d.new(other_vertex)  # => a copy of other_vertex

  def to_s
    self.inspect
  end

  # Returns the calculated magnitude of this point, represented as a vector from the origin (0,0,0).
  def magnitude; Math.sqrt x*x + y*y + z*z; end

  # Returns the calculated distance between the supplied Vertex3d and this one.
  def distance(*vertex) v = vertex.extract_vector3i!; Math.sqrt(((v[0]-x) ** 2) + ((v[1]-y) ** 2 ) + ((v[2]-z) ** 2)) end
  alias distance_from distance

  # Scales this vertex by the specified amount, which can be one number, three numbers (one for each
  # axis), or another Vertex3d. This vertex is treated as a vector from the origin (0,0,0), and the specified
  # amount is always treated as the x, y and z amount to multiply the vector against.
  #
  # This vector is returned after all modifications have been made so that method chaining is possible.
  # Ex:
  #   puts Vertex3d.new(0.5, 0.1, 1.0).scale!(25, 50, 75).magnitude
  def scale!(*amount)
    x, y, z = amount.extract_vector3i!

    self.x, self.y, self.z = self.x*x, self.y*y, self.z*z
    self
  end

  # Computes the dot product between this Vertex3d and the specified one. Both vertices are treated
  # as vectors for this calculation. If both vectors are normal (they have magnitude == 1), then the
  # dot product returns the cosine of the angle between the two vectors, using the point (0,0,0) as
  # the origin.
  #
  # See also #magnitude, #normalize!
  def dot(*args)
    vx, vy, vz = args.extract_vector3i!
    x * vx + y * vy + z * vz
  end

  # Returns true if the magnitude of this vector equals 1, false otherwise.
  def normal?
    magnitude == 1
  end

  # Normalizes this vector so that its magnitude is equal to 1, unless its magnitude is already equal
  # to 0 (in that case all axes are equal to 0 and the vector is returned without modification).
  #
  # Returns itself after normalization, so method chaining is possible.
  # Ex:
  #   puts "Vector has been normalized" if Vertex3d.new(25, 75, 100).normalize!.normal?
  def normalize!
    mag = magnitude
    return self if mag == 0
    self.x, self.y, self.z = self.x / mag, self.y / mag, self.z / mag
    self
  end

  # Returns a scaled version of this Vertex3d without modifying this Vertex3d itself.
  # See #scale!
  def scale(*amount)
    self.dup.scale! *amount
  end

  # Converts self into a vector that is perpendicular to to both A (this) and B (v) and then returns self.
  #   A x B = <Ay*Bz - Az*By, Az*Bx - Ax*Bz, Ax*By - Ay*Bx>
  def cross!(*args)
    vx, vy, vz = args.extract_vector3i!
    self.x, self.y, self.z = y * vz - z * vy, z * vx - x * vz, x * vy - y * vx
    self
  end

  # Returns a normalized version of this Vertex3d without modifying this Vertex3d itself.
  # See #normalize!
  def normalize
    self.dup.normalize!
  end

  # Returns the cross product between this Vertex3d and the specified Vertex3d without modifying either object.
  # See #cross!
  def cross(*v)
    self.dup.cross! *v
  end

  def inspect #:nodoc:
    "<#{x}, #{y}, #{z}>"
  end

  # Unary - operator. Like -1 produces a negative 1 and -(-1) produces a positive 1, the same holds for
  # this Vertex3d, in which case it is applied to all 3 axes.
  # Ex:
  #  p -(Vertex3d.new(1,1,1)) # => <-1,-1,-1>
  def -@
    self.class.new(-x, -y, -z)
  end

  ["+", "-", "*", "/", "**"].each do |op|
    line = __LINE__ + 2
    code = <<-end_code
      def #{op}(*args)
        a, b, c = args.extract_vector3i!
        self.class.new(@x #{op} a, @y #{op} b, @z #{op} c)
      end     
    end_code
    eval code, binding, __FILE__, line
  end

  # Returns the axes of this Vertex3d in array form. Ex:
  #   p Vertex3d.new(1,2,3).to_a # => [ 1, 2, 3 ]
  def to_a
    [ x, y, z ]
  end
end
