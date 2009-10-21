class Matrix
  def []=(i,j,x)
    @rows[i][j] = x
  end

  def load_identity!
    row_size.times do |r|
      column_size.times do |c|
        self[r, c] = (r == c ? 1 : 0)
      end
    end
    self
  end

  def look_at!(position, view, up)
    load_identity!

    side = forward.cross(up).normalize
    up = side.cross(forward)

    self[0,0] = side.x
    self[1,0] = side.y
    self[2,0] = side.z

    self[0,1] = up.x
    self[1,1] = up.y
    self[2,1] = up.z

    self[0,2] = -view.x
    self[1,2] = -view.y
    self[2,2] = -view.z

    translate! position
  end

  def translate!(v)
    4.times { |i| self[3,i] = self[0,i] * v.x + self[1,i] * v.y + self[2,i] * v.z + self[3,i] }
    self
  end

  def translate_to!(v)
    self[3,0] = v.x
    self[3,1] = v.y
    self[3,2] = v.z
    self[3,3] = 1
    self
  end
end
