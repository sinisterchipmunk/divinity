class Geometry::Vector3d < Geometry::Vertex3d
  include Math

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
