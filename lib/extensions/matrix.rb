class Matrix
  def []=(i,j,x)
    @rows[i][j] = x
  end

  def look_at!(position, view, up)
    forward = (view - position).normalize!
    side = forward.cross(up).normalize!
    up = side.cross(forward)

    self[0,0] = side.x
    self[1,0] = side.y
    self[2,0] = side.z

    self[0,1] = up.x
    self[1,1] = up.y
    self[2,1] = up.z

    self[0,2] = -forward.x
    self[1,2] = -forward.y
    self[2,2] = -forward.z

    translate! position
  end

  def translate!(v)
    4.times { |i| self[3,i] = self[0,i] * v.x + self[1,i] * v.y + self[2,i] * v.z + self[3,i] }
    self
  end

  def translate_to!(v)
    self[0,3] = v.x
    self[1,3] = v.y
    self[2,3] = v.z
    self
  end
end
