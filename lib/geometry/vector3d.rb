# Represents a single point in 3D space.
# This class is mirrored as Geometry::Vertex3d.
class Geometry::Vector3d
  include Math

  attr_accessor :x, :y, :z

  # Returns true if this vector is orthogonal with the specified vector.
  def orthogonal_with?(a); self.dot(a) == 0; end

  # Returns this vector projected onto the specified one
  def project_onto(a)
    a * self.dot(a.normalize)
  end

  # Returns the angle between this vector and the supplied one
  def angle(*args)
    Math.acos(self.dot(*args))
  end

  # A Vector3d object can be initialized in any of the following ways:
  #
  #  Vector3d.new(0, 1, 2)  # => x: 0, y: 1, z: 2
  #  Vector3d.new [0, 1, 2) # => x: 0, y: 1, z: 2
  #  Vector3d.new(other_vertex)  # => a copy of other_vertex
  def to_s
    self.inspect
  end

  # Returns the calculated magnitude of this point, represented as a vector from the origin (0,0,0).
  def magnitude; Math.sqrt x*x + y*y + z*z; end

  # Returns the calculated distance between the supplied Vector3d and this one.
  def distance(*vertex) v = vertex.extract_vector3i!; Math.sqrt(((v[0]-x) ** 2) + ((v[1]-y) ** 2 ) + ((v[2]-z) ** 2)) end
  alias distance_from distance

  # Scales this vertex by the specified amount, which can be one number, three numbers (one for each
  # axis), or another Vector3d. This vertex is treated as a vector from the origin (0,0,0), and the specified
  # amount is always treated as the x, y and z amount to multiply the vector against.
  #
  # This vector is returned after all modifications have been made so that method chaining is possible.
  # Ex:
  #   puts Vector3d.new(0.5, 0.1, 1.0).scale!(25, 50, 75).magnitude
  def scale!(*amount)
    x, y, z = amount.extract_vector3i!

    self.x, self.y, self.z = self.x*x, self.y*y, self.z*z
    self
  end

  # Computes the dot product between this Vector3d and the specified one. Both vertices are treated
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
  #   puts "Vector has been normalized" if Vector3d.new(25, 75, 100).normalize!.normal?
  def normalize!
    mag = magnitude
    return self if mag == 0
    self.x, self.y, self.z = self.x / mag, self.y / mag, self.z / mag
    self
  end

  # Returns a scaled version of this Vector3d without modifying this Vector3d itself.
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

  # Returns a normalized version of this Vector3d without modifying this Vector3d itself.
  # See #normalize!
  def normalize
    self.dup.normalize!
  end

  # Returns the cross product between this Vector3d and the specified Vector3d without modifying either object.
  # See #cross!
  def cross(*v)
    self.dup.cross! *v
  end

  def inspect #:nodoc:
    "<#{x}, #{y}, #{z}>"
  end

  # Unary - operator. Like -1 produces a negative 1 and -(-1) produces a positive 1, the same holds for
  # this Vector3d, in which case it is applied to all 3 axes.
  # Ex:
  #  p -(Vector3d.new(1,1,1)) # => <-1,-1,-1>
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

  # Returns the axes of this Vector3d in array form. Ex:
  #   p Vector3d.new(1,2,3).to_a # => [ 1, 2, 3 ]
  def to_a
    [ x, y, z ]
  end
  
  # Rotate this vector around the axis of the specified vector. For instance, to rotate a view vector
  # upward ("look up"), you'd rotate it along the vector perpendicular to the view and up vectors:
  #
  #   view.rotate! angle, view.cross(up)
  #
  # This is also known as the "right vector" because it is at a right angle to the forward and up vectors,
  # and points along the positive local X axis ('right'). Calling up.cross(view) [reversing the arguments]
  # points the resultant vector along the negative local X axis, or "left".
  #
  # Hope that made sense. I'm not very good at explaining this stuff.
  #
  def rotate!(angle, *args)
    x, y, z = if args.length == 1 then [args[0].x, args[0].y, args[0].z]
    elsif args.length == 3 then [args[0], args[1], args[2]]
    elsif args.length == 4 then raise "Four dimensional vector rotation is not yet implemented"
    else raise "Expected either a Vector3d or x, y and z arguments"
    end


    # Calculate the sine and cosine of the angle once
    costheta = cos(angle)
    sintheta = sin(angle)

    # Find the new x position of the rotated vector
    rx = (costheta + (1 - costheta) * x * x)     * self.x +
         ((1 - costheta) * x * y - z * sintheta) * self.y +
	     ((1 - costheta) * x * z + y * sintheta) * self.z

	# Find the new y position for the new rotated point
    ry = ((1 - costheta) * x * y + z * sintheta) * self.x +
	     (costheta + (1 - costheta) * y * y)     * self.y +
	     ((1 - costheta) * y * z - x * sintheta) * self.z

	# Find the new z position for the new rotated point
	rz = ((1 - costheta) * x * z - y * sintheta) * self.x +
	     ((1 - costheta) * y * z + x * sintheta) * self.y +
	     (costheta + (1 - costheta) * z * z)     * self.z

    self.x, self.y, self.z = rx, ry, rz
    self
  end

  def rotate(angle, x, y, z, w = nil)
    self.dup.rotate! angle, x, y, z, w
  end
end
