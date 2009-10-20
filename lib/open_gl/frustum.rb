class OpenGl::Frustum
  include Helpers::XyzHelper
  include Geometry
  SIDES = [ :right, :left, :top, :bottom, :near, :far ]

  attr_reader :planes, :modelview

  def initialize
    @planes = { }
    @modelview = Array.new(16) { 0.0 }
    @clip = Array.new(16) { 0.0 }
    SIDES.each { |k| @planes[k] = Plane.new }
  end

  def point_visible?(*point)
    sphere_visible? 0, *point
  end

  def sphere_visible?(radius, *point)
    r, x, y, z = radius, *xyz(*point)
    planes.each { |side, plane| return false if plane.a*x + plane.b*y + plane.c*z + plane.d <= -radius }
    true
  end

  def cube_visible?(size, *point)
    s, x, y, z = radius, *xyz(*point)
    planes.each do |side, plane|
      next if (plane.a * (x - size) + plane.b * (y - size) + plane.c * (z - size) + plane.d > 0) ||
              (plane.a * (x + size) + plane.b * (y - size) + plane.c * (z - size) + plane.d > 0) ||
              (plane.a * (x - size) + plane.b * (y + size) + plane.c * (z - size) + plane.d > 0) ||
              (plane.a * (x + size) + plane.b * (y + size) + plane.c * (z - size) + plane.d > 0) ||
              (plane.a * (x - size) + plane.b * (y - size) + plane.c * (z + size) + plane.d > 0) ||
              (plane.a * (x + size) + plane.b * (y - size) + plane.c * (z + size) + plane.d > 0) ||
              (plane.a * (x - size) + plane.b * (y + size) + plane.c * (z + size) + plane.d > 0) ||
              (plane.a * (x + size) + plane.b * (y + size) + plane.c * (z + size) + plane.d > 0)
      return false
    end
    true
  end

  # Updating the Frustum is EXPENSIVE and should only be done when necessary -- but must be done
  # every time the matrix changes! (When the camera is moved, rotated, or whatever.)
  def update!
    proj, @modelview = glGetDoublev(GL_PROJECTION_MATRIX).flatten, glGetDoublev(GL_MODELVIEW_MATRIX)
    modl = self.modelview.flatten

    ## Brutally ripped from my old C++ code, then reformatted to match the new Ruby classes. Math hasn't changed.
    # I'm not huge on math, and TBH I don't really have a firm understanding of what's happening here. Somehow,
    # we are waving a magic wand and extracting the 6 planes which will represent the edges of the
    # camera's viewable area. I'll let someone who's familiar with matrices explain how that happens.
    # In any case, it works, and I have a lot of other things to do, so I just copy and paste it from
    # one 3D app to the next.
    @clip[ 0] = modl[ 0] * proj[ 0] + modl[ 1] * proj[ 4] + modl[ 2] * proj[ 8] + modl[ 3] * proj[12];
    @clip[ 1] = modl[ 0] * proj[ 1] + modl[ 1] * proj[ 5] + modl[ 2] * proj[ 9] + modl[ 3] * proj[13];
    @clip[ 2] = modl[ 0] * proj[ 2] + modl[ 1] * proj[ 6] + modl[ 2] * proj[10] + modl[ 3] * proj[14];
    @clip[ 3] = modl[ 0] * proj[ 3] + modl[ 1] * proj[ 7] + modl[ 2] * proj[11] + modl[ 3] * proj[15];

    @clip[ 4] = modl[ 4] * proj[ 0] + modl[ 5] * proj[ 4] + modl[ 6] * proj[ 8] + modl[ 7] * proj[12];
    @clip[ 5] = modl[ 4] * proj[ 1] + modl[ 5] * proj[ 5] + modl[ 6] * proj[ 9] + modl[ 7] * proj[13];
    @clip[ 6] = modl[ 4] * proj[ 2] + modl[ 5] * proj[ 6] + modl[ 6] * proj[10] + modl[ 7] * proj[14];
    @clip[ 7] = modl[ 4] * proj[ 3] + modl[ 5] * proj[ 7] + modl[ 6] * proj[11] + modl[ 7] * proj[15];

    @clip[ 8] = modl[ 8] * proj[ 0] + modl[ 9] * proj[ 4] + modl[10] * proj[ 8] + modl[11] * proj[12];
    @clip[ 9] = modl[ 8] * proj[ 1] + modl[ 9] * proj[ 5] + modl[10] * proj[ 9] + modl[11] * proj[13];
    @clip[10] = modl[ 8] * proj[ 2] + modl[ 9] * proj[ 6] + modl[10] * proj[10] + modl[11] * proj[14];
    @clip[11] = modl[ 8] * proj[ 3] + modl[ 9] * proj[ 7] + modl[10] * proj[11] + modl[11] * proj[15];

    @clip[12] = modl[12] * proj[ 0] + modl[13] * proj[ 4] + modl[14] * proj[ 8] + modl[15] * proj[12];
    @clip[13] = modl[12] * proj[ 1] + modl[13] * proj[ 5] + modl[14] * proj[ 9] + modl[15] * proj[13];
    @clip[14] = modl[12] * proj[ 2] + modl[13] * proj[ 6] + modl[14] * proj[10] + modl[15] * proj[14];
    @clip[15] = modl[12] * proj[ 3] + modl[13] * proj[ 7] + modl[14] * proj[11] + modl[15] * proj[15];

    right.a = @clip[ 3] - @clip[ 0];
    right.b = @clip[ 7] - @clip[ 4];
    right.c = @clip[11] - @clip[ 8];
    right.d = @clip[15] - @clip[12];

    left.a = @clip[ 3] + @clip[ 0];
    left.b = @clip[ 7] + @clip[ 4];
    left.c = @clip[11] + @clip[ 8];
    left.d = @clip[15] + @clip[12];

    bottom.a = @clip[ 3] + @clip[ 1];
    bottom.b = @clip[ 7] + @clip[ 5];
    bottom.c = @clip[11] + @clip[ 9];
    bottom.d = @clip[15] + @clip[13];

    top.a = @clip[ 3] - @clip[ 0];
    top.b = @clip[ 7] - @clip[ 4];
    top.c = @clip[11] - @clip[ 8];
    top.d = @clip[15] - @clip[12];

    far.a = @clip[ 3] - @clip[ 2];
    far.b = @clip[ 7] - @clip[ 6];
    far.c = @clip[11] - @clip[10];
    far.d = @clip[15] - @clip[14];

    near.a = @clip[ 3] + @clip[ 2];
    near.b = @clip[ 7] + @clip[ 6];
    near.c = @clip[11] + @clip[10];
    near.d = @clip[15] + @clip[14];

    normalize_planes!
    self
  end

  SIDES.each { |k| eval("def #{k}; @planes[#{k.inspect}]; end", binding, __FILE__, __LINE__)}

  private
  def normalize_planes!
    planes.each { |side, plane| plane.normalize! }
  end
end
