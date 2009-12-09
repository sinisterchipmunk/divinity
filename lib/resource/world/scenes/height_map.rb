class Resource::World::Scenes::HeightMap < Resource::World::Scene
  include Geometry
  include Helpers::RenderHelper

  attr_reader :image
  attr_accessor :magnitude

  delegate :width, :to => :image
  def length; image.height; end

  def initialize(engine, path, magnitude = 10)
    super(engine)
    @image = Resources::Image.new(path)
    @depth = ((1 << image.depth) - 1).to_f# if it's an 8-bit image, then the depth will be between (1<<8)-1, or 0 - 255.
    @map = image.image_list.export_pixels(0, 0, image.width, image.height, "I")
    @magnitude = magnitude
    @display_list = OpenGl::DisplayList.new { render_without_display_list }
  end

  def height_at(*a)
    x, y = x_and_y(*a)
    if x < 0 or y < 0 or x >= image.width or y >= image.height
      raise "Position [#{x},#{y}] is beyond the bounds of this height map [#{image.width},#{image.height}]"
    end
    offset = (image.width * y) + x
    if offset < 0 || offset >= @map.length
      raise "Index at [#{x},#{y}] translates to offset #{offset} and is outside of range 0..#{@map.length}!"
    end
    @map[offset] / @depth * magnitude
  end

  ## TODO: After initial construction, pieces of height map should be fed into an octree for culling.
  def render
    super do
      @display_list.call
    end
  end

  def render_without_display_list
    glTranslatef(-(width/3)*2, -magnitude, -(length/2))
    glDisable GL_TEXTURE_2D
      glBegin GL_TRIANGLE_STRIP
        (0...(width-2)).step(2) do |x|
          # Quick explanation. What we're doing here is tristrip up, then tristrip back down to 0, incrementing
          # x when we do it. This essentially connects the first tristrip with the second and leaves us in position
          # for the third, saving us those calls to glBegin and glEnd. For a height map that's 300 strips wide,
          # we save 600 method calls -- 300 saved on glBegin calls, and 300 saved on glEnd calls. It's the little
          # things in life...
          x_plus_one, x_plus_two = x+1, x+2
          length.times { |z| vertex [x, z], [x_plus_one, z] }
          (0...length).to_a.reverse.each { |z| vertex [x_plus_one, z], [x_plus_two, z] }
        end
      glEnd
    glEnable GL_TEXTURE_2D
    glTranslatef( (width/3)*2,  magnitude,  (length/2))
  end

  private
  def vertex(*points)
    points.each do |arr|
      x, z = x_and_y(*arr)
      y = height_at(x, z)
      color = (y + (magnitude / 2.0)) / (magnitude * 1.5)
      glColor4f color, color, color, 1
      glTexCoord2f(x / width.to_f, z / length.to_f)
      glVertex3f(x, y, z)
    end
  end

  def x_and_y(*a)
    if a.length == 1 then
      if a[0].kind_of? Array then a[0]
      elsif a[0].kind_of? Fixnum then # just one numeric argument supplied, assume it's an array offset
        [a[0] % image.height, (a[0] / image.height).floor]
      else [a[0].x, a[0].y]
      end
    else a
    end
  end
end
