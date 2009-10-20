class OpenGl::Camera
  include Geometry

  # the position of the camera
  attr_accessor :position

  # the view and up vectors for this camera, in relation to the camera itself (#position is the origin)
  attr_accessor :view, :up
  attr_reader :matrix, :frustum
  delegate :update!, :point_visible?, :cube_visible?, :sphere_visible?, :to => :frustum

  def view=(a); @view = a; @right = @view.cross(@up) end
  def up=(a); @up = a; @right = @view.cross(@up) end

  # Takes the position, view and up vectors in that order, in the form of either 3 Vectors / Vertexes (p, v, u) or
  # 9 Floats (px, py, pz, vx, vy, vz, ux, uy, uz)
  def initialize(*args)
    args = [0,1.5,6, 0,1.5,0, 0,1,0] if args.empty?
    @position = Vertex3d.new(0, 0, 0)
    @view = Vector3d.new(0, 0, -1)
    @up = Vector3d.new(0, 1, 0)

    #@maintain_up_vector = true
    @lock_y_axis = false

    @last_rot_x, @cur_rot_x = 0.0, 0.0

    if args.length == 3 # Vectors / Vertices
      @position, @view, @up = args
    elsif args.length == 9 # Floats
      position.x, position.y, position.z, view.x, view.y, view.z, up.x, up.y, up.z = args
    else raise "Expected either 3 Vectors (p, v, u) or 9 Floats (px, py, pz, vx, vy, vz, ux, uy, uz) as arguments"
    end

    @right = @view.cross(@up)

    @frustum = OpenGl::Frustum.new
    @matrix = Matrix.identity(4)
  end

  # Rotates the view vector of this Camera, effecting a "look" in a rotated direction. This is very useful
  # when linked with mouse coordinates, or joystick axes, for instance.
  # Examples:
  #
  #   on :mouse_moved do |evt|
  #     # get this is the change in mouse coordinates between the last update and this one
  #     extent_x, extent_y = evt.xrel, evt.yrel
  #     # moving the mouse vertically will rotate along the X axis, while moving it horizontally will rotate along
  #     # the Y axis. This simulates a first-person shooter camera. The camera is not rotated along the Z axis.
  #     camera.rotate_view! extent_y, extent_x, 0
  #   end
  #
  #   # this is also valid:
  #   camera.rotate_view! Vector.new(extent_x, extent_y, extent_z)
  #
  def rotate_view!(*args)
    x, y, z = if args.length == 0 then args.to_a else args end
    #x' = m1x + n1y + l1z
    #y' = m2x + n2y + l2z
    #z' = m3x + n3y + l3z
    #  where the origins of the xyz and x'y'z' systems are the same and m1, n1, l1; m2, n2, l2; m3, n3, l3 are the
    #  direction cosines of the x', y', z' axes relative to the x, y, z-axes respectively
    @alpha = 0
    @beta = 1.5708
    @gamma = 0
    #rotate_x!(x).rotate_y!(y).rotate_z!(z)
  end

  def rotate_x!(amount)
    [:x, :y, :z].each do |axis|
      v,r = view.send(axis),right.send(axis)
      view.send("#{axis}=", (cos(1.5708 + amount) * v) + (cos(amount) * r))# + (cos(1.5708 - amount) * up.x) always == 0
      right.send("#{axis}=", (cos(amount) * v) + (cos(1.5708 - amount) * r))# + (cos(1.5708 + amount) * up.x)
    end

    # no need to update up vector because we're only moving along the XZ axes
    view.normalize!
    right.normalize!
    self
  end

  # Returns whether or not the up vector will be updated whenever the view is rotated. Whether this is useful to
  # you depends entirely on what kind of camera you need; if you need a "floating" camera such as a flight simulator,
  # then you probably want this enabled, otherwise you'll hit Gimble lock when the total rotation of the view vector
  # is greater than 1.0 or less than -1.0. (In practice, this value is maxed out at 1.0 or -1.0 whenever
  # #maintain_up_vector? is set to false, which prevents the camera from attempting a full rotation.)
  #
  # However, if you need more of a first-person type of camera, in which the user can't generally turn their head
  # upside-down, then you'll want this *disabled*. When rotating, the Camera class will automatically max out the
  # view vector's rotation at 1.0 (straight up) or -1.0 (straight down) in order to avoid Gimble lock, and this will
  # keep the player from rotating the camera into unrealistic angles. Defaults to true. See also #maintain_up_vector!
  def maintain_up_vector?; @maintain_up_vector; end

  # Returns whether or not the up vector will be updated whenever the view is rotated. Whether this is useful to
  # you depends entirely on what kind of camera you need; if you need a "floating" camera such as a flight simulator,
  # then you probably want this enabled, otherwise you'll hit Gimble lock when the total rotation of the view vector
  # is greater than 1.0 or less than -1.0. (In practice, this value is maxed out at 1.0 or -1.0 whenever
  # #maintain_up_vector? is set to false, which prevents the camera from attempting a full rotation.)
  #
  # However, if you need more of a first-person type of camera, in which the user can't generally turn their head
  # upside-down, then you'll want this *disabled*. When rotating, the Camera class will automatically max out the
  # view vector's rotation at 1.0 (straight up) or -1.0 (straight down) in order to avoid Gimble lock, and this will
  # keep the player from rotating the camera into unrealistic angles. Defaults to true. See also #maintain_up_vector!
  def maintain_up_vector!(a = true); @maintain_up_vector = a; end

  # If true, this will prevent the camera from #move!-ing or #strafe!-ing along the Y axis. Defaults to false.
  def lock_y_axis?; @lock_y_axis; end

  # If true, this will prevent the camera from #move!-ing or #strafe!-ing along the Y axis. Defaults to false.
  def lock_y_axis!(a = true); @lock_y_axis = a; end

  # Moves left or right, in relation to the supplied vector or in relation to the camera's current orientation
  def strafe!(distance, *args)
    front = nil
    if args.length == 0 then front = (view - position)
    else front = Vertex3d.new *args
    end
    direction = front.cross!(up).normalize!
    direction.y = 0 if lock_y_axis?
    direction *= distance
    self.position += direction
    matrix.look_at! position, view, up
    self
  end

  # Moves forward or back, in relation to the supplied vector or in relation to the camera's current orientation
  def move!(distance, *args)
    direction = nil
    if args.length == 0 then direction = (view - position)
    else direction = Vertex3d.new *args
    end
    direction.normalize!
    direction.y = 0 if lock_y_axis?
    direction *= distance
    self.position += direction
    self.view += direction
    matrix.look_at! position, view, up
    self
  end

  # Translates the camera's current coordinates to the specified position -- either 3 numbers (x, y, z) or a Vertex
  def move_to!(*args)
    point = args[0]
    point = Vertex3d.new(*args) if args.length == 3
    self.view = view - position + point
    self.position = point
    matrix.look_at! position, view, up
    self
  end

  alias translate_to! move_to!

  # Translates the camera's current coordinates by the supplied amount -- either 3 numbers (x, y, z) or a Vector
  def translate!(*args)
    amount = args[0]
    amount = Vector3d.new(*args) if args.length == 3
    self.view += amount
    self.position += amount
    matrix.look_at! position, view, up
    self
  end

  # Merges all of the vectors that make up the supplied camera with this one, and then updates the matrix.
  def merge!(camera)
    self.position, self.view, self.up = camera.position, camera.view, camera.up
    self.matrix.look_at!(position, view, up)
    self
  end

  # Applies the matrix that belongs to this Camera to OpenGL, and then updates its Frustum.
  def look!
    glLoadMatrixf(matrix)
    frustum.update!
    self
  end
end
