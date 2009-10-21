class Geometry::Vector3d < Geometry::Vertex3d
  include Math

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
