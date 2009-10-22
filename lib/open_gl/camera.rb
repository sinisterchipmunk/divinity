# The Camera is an important part of the game, because it is your end user's "eyes". It's important to know
# how to use it, because the mechanics that control your Camera will make the difference between an
# immersive game and a quirky demo.
#
# Luckily, all of the hard work has been abstracted out and away from you; you only have to decide what basic
# rules your Camera has to follow. You can do this through an instance of the DivinityEngine without instantiating
# the Camera directly; however, there's nothing stopping you from doing so. Be sure to call #look! whenever you
# are ready to apply the Camera's current transformations to the OpenGL matrix. This will also update the
# Camera's Frustum object.
#
# As mentioned, you need to decide how your Camera is going to respond to input. There are two control methods
# you can use to this end: #lock_up_vector! and #lock_y_axis! -- you should have a thorough understanding
# of how each of these works (and whether you need to enable or disable them) before attempting to use the Camera
# class. See also #lock_up_vector? and #lock_y_axis?
#
class OpenGl::Camera
  include Geometry
  include Math

  # the position of the camera
  attr_accessor :position

  # the view, up and right vectors for this camera, in relation to the camera itself (#position is the origin)
  attr_accessor :view, :up, :right
  attr_reader :matrix, :frustum
  delegate :point_visible?, :cube_visible?, :sphere_visible?, :to => :frustum

  def view=(a); @view = a; @right = @view.cross(@up) end
  def up=(a); @up = a; @right = @view.cross(@up) end

  def initialize(*args)
    @position = Vertex3d.new(0, 0, 0)
    @view = Vector3d.new(0, 0, -1)
    @up = Vector3d.new(0, 1, 0)
    @right = @view.cross(@up)

    @lock_up_vector = false
    @lock_y_axis = false

    @frustum = OpenGl::Frustum.new
    @matrix = Matrix.identity(4)

    matrix.look_at! position, view, up
  end

  # Rotates the view vector of this Camera, effecting a "look" in a rotated direction. This is very useful
  # when linked with mouse coordinates, or joystick axes, for instance.
  # Examples:
  #
  #   divinity.on :mouse_moved do |evt|
  #     # this is the change in mouse coordinates between the last update and this one
  #     # we have to water it down a bit (/ 100) because it's too big to pass directly into the camera
  #     x_extent, y_extent = evt.xrel / 100, evt.yrel / 100
  #     # moving the mouse vertically will rotate along the X axis, while moving it horizontally will rotate along
  #     # the Y axis. This simulates a first-person shooter camera. The camera is not rotated along the Z axis.
  #     divinity.rotate_view! -y_extent, -x_extent, 0
  #   end
  #
  #   # this is also valid:
  #   camera.rotate_view! Vector.new(extent_x, extent_y, extent_z)
  #
  def rotate_view!(*args)
    amount_x, amount_y, amount_z = if args.length == 0 then args.to_a else args end
    amount_y = -amount_y # because the user is expecting positive amount to rotate right, not left
    amount_z = 0 if amount_z.nil? # if the user forgets to supply a Z axis, let's forgive them.

    if amount_x != 0 # effectively "looking up/down"
      view.rotate! amount_x, right
      unless lock_up_vector?
        @up = right.cross(view).normalize!
      end
    end

    if amount_y != 0 # effectively "looking left/right"
      view.rotate! amount_y, up
      @right = view.cross(up).normalize!
    end

    if amount_z != 0 # effectively rotating clockwise/counterclockwise
      up.rotate! amount_z, view
      @right = view.cross(up).normalize!
    end

    view.normalize!

    if lock_up_vector?
      # prevent view from rotating too far
      #angle = asin(view.dot(@up))#acos(view.dot(@up))
      # FIXME: I really hate these hard numbers -- and it may be because I'm really tired right now - but I can't figure
      # out a better way to detect this. Seems to work, in any case, but it may fail if amount_x is too high.
      angle = acos(view.dot(@up)) - 0.05
      if angle != 0
        angle = -angle if angle >= 3 - 0.05
        angle /= angle.abs # we want 1 or -1
        @last_angle = angle if @last_angle.nil?
        if angle != @last_angle and amount_x != 0
          rotate_view! -amount_x, 0, 0
        else
          @last_angle = angle
        end
      end
    end
    matrix.look_at! position, view, up
    self
  end

  # Returns whether or not the up vector will be updated whenever the view is rotated. Whether this is useful to
  # you depends entirely on what kind of camera you need; if you need a "floating" camera such as a flight simulator,
  # then you probably want this disabled so that the Camera is capable of rotating to an upside-down state.
  #
  # However, if you need more of a first-person type of camera, in which the user can't generally turn their head
  # upside-down, then you'll want this *enabled*. When rotating, the Camera class will automatically max out the
  # view vector's rotation at "straight up" or "straight down" in order to avoid strange side effects, and this will
  # keep the player from rotating the camera into unrealistic angles. Defaults to false. See also #lock_up_vector!
  def lock_up_vector?; @lock_up_vector; end

  # Enables or disables automatic updating of the up vector whenever the view is rotated. Whether this is useful to
  # you depends entirely on what kind of camera you need; if you need a "floating" camera such as a flight simulator,
  # then you probably want this disabled so that the Camera is capable of rotating to an upside-down state.
  #
  # However, if you need more of a first-person type of camera, in which the user can't generally turn their head
  # upside-down, then you'll want this *enabled*. When rotating, the Camera class will automatically max out the
  # view vector's rotation at "straight up" or "straight down" in order to avoid strange side effects, and this will
  # keep the player from rotating the camera into unrealistic angles. Defaults to false. See also #lock_up_vector!
  def lock_up_vector!(a = true); @lock_up_vector = a; end

  # If true, this will prevent movement along the Y axis. Note that this is the Y axis in *worldspace*, so
  # your world should be oriented such that the positive Y axis is facing "up". For this reason, it's generally most
  # effective when combined with an up vector of (0,1,0) and #lock_up_vector!.
  #
  # Locking the Y axis essentially creates a quick-and-dirty feeling of gravity; it doesn't prevent you from directly
  # manipulating the translation of the camera, so you can still have the user "jump" and then pull him back down to
  # the floor. They just won't be able to point their camera at the sky, go "forward", and "fly".
  def lock_y_axis?; @lock_y_axis; end

  # Enables or disables preventing of movement along the Y axis. Note that this is the Y axis in *worldspace*, so
  # your world should be oriented such that the positive Y axis is facing "up". For this reason, it's generally most
  # effective when combined with an up vector of (0,1,0) and #lock_up_vector!.
  #
  # Locking the Y axis essentially creates a quick-and-dirty feeling of gravity; it doesn't prevent you from directly
  # manipulating the translation of the camera, so you can still have the user "jump" and then pull him back down to
  # the floor. They just won't be able to point their camera at the sky, go "forward", and "fly".
  def lock_y_axis!(a = true); @lock_y_axis = a; end

  # Moves left or right, in relation to the supplied vector or in relation to the camera's current orientation
  def strafe!(distance, *args)
    front = nil
    if args.length == 0 then front = view.dup
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
    if args.length == 0 then direction = view.dup
    else direction = Vertex3d.new *args
    end
    direction.normalize!
    direction.y = 0 if lock_y_axis?
    direction *= distance
    self.position += direction
    matrix.look_at! position, view, up
    self
  end

  # Translates the camera's current coordinates to the specified world position, ignoring its local axes.
  # The right, up and view vectors remain the same, since they are relative to the camera's position.
  #
  # Arguments are either 3 numbers (x, y, z) or a Vertex.
  # This method ignores the state of #lock_y_axis?
  def translate_to!(*args)
    point = args[0]
    point = Vertex3d.new(*args) if args.length == 3
    self.position = point
    matrix.translate_to! position
    self
  end

  alias move_to! translate_to!

  # Translates the camera's current coordinates by the supplied amount, relative to its current orientation.
  # For instance, if it is translated 0, 1, 0 (one unit on the positive Y axis), that will be converted into
  # "one unit towards the up vector". Use #translate_to!(camera.position+translation) if you want to translate
  # relative to worldspace (ignoring the right, up and view vectors).
  #
  # The right, view and up vectors are not modified by this method, because they are relative to the camera's
  # position.
  #
  # Arguments are either 3 numbers (x, y, z) or a Vector
  # This method ignores the state of #lock_y_axis?
  def translate!(*args)
    amount = args[0]
    amount = Vector3d.new(*args) if args.length == 3
    self.position += (right*amount.x) + (up*amount.y) + (view*amount.z)
    matrix.translate_to! position
    self
  end

  # Applies the matrix that belongs to this Camera to OpenGL, and then updates its Frustum.
  def look!
    #gluLookAt(position.x, position.y, position.z, view.x+position.x, view.y+position.y, view.z+position.z, up.x, up.y, up.z)
    glLoadMatrixf(matrix)
    frustum.update!
    self
  end
end
