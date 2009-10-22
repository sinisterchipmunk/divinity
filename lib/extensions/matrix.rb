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

    side = view.cross(up).normalize
    up = side.cross(view)

    self[0,0] = side.x
    self[1,0] = side.y
    self[2,0] = side.z

    self[0,1] = up.x
    self[1,1] = up.y
    self[2,1] = up.z

    self[0,2] = -view.x
    self[1,2] = -view.y
    self[2,2] = -view.z

    translate_to! position
  end

  def translate!(v)
    4.times { |i| self[3,i] = self[0,i] * -v.x + self[1,i] * -v.y + self[2,i] * -v.z + self[3,i] }
    self
  end

  def translate_to!(v)
    4.times { |i| self[3,i] = -v.x * self[0,i] + -v.y * self[1,i] + -v.z * self[2,i] }
    self[3,3] += 1 # for the lower-right identity
    self
  end
end
