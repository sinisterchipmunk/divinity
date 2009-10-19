class World::Scenes::HeightMap < World::Scene
  include Geometry
  include Helpers::RenderHelper

  attr_reader :image
  attr_accessor :magnitude

  delegate :width, :height, :to => :image

  def initialize(path, magnitude = 10)
    super()
    @image = Resources::Image.new(path)
    @depth = ((1 << image.depth) - 1).to_f# if it's an 8-bit image, then the depth will be between (1<<8)-1, or 0 - 255.
    @map = image.image_list.export_pixels(0, 0, image.width, image.height, "I")
    @magnitude = magnitude
    @display_list = OpenGL::DisplayList.new { render_without_display_list }
  end

  def depth_at(*a)
    x, y = x_and_y(*a)
    offset = (image.width * y) + x
    if offset < 0 || offset >= @map.length
      raise "Index at [#{x},#{y}] translates to offset #{offset} and is outside of range 0..#{@map.length}! (Image is #{image.width}x#{image.height})"
    end
    @map[offset] / @depth * magnitude
  end

  def render
    #render_without_display_list
    @display_list.call
  end

  def render_without_display_list
    push_matrix do
      glLoadIdentity
      glTranslatef(-(width/3)*2,-magnitude,-(height/2))
#      wireframe do
        glDisable GL_TEXTURE_2D
        #@image.bind do
          (width-1).times do |x|
            glBegin GL_TRIANGLE_STRIP
              (height).times do |y|
                depth = depth_at(x, y)
                color = (depth + (magnitude / 2.0)) / (magnitude * 1.5)
                glColor4f color, color, color, 1
                glTexCoord2f(x / width.to_f, y / height.to_f)
                glVertex3f(x, depth, y)

                depth = depth_at(x+1, y)
                color = (depth + (magnitude / 2.0)) / (magnitude * 1.5)
                glColor4f color, color, color, 1
                glTexCoord2f((x+1) / width.to_f, y / height.to_f)
                glVertex3f(x+1, depth, y)
              end
            glEnd
          end
        glEnable GL_TEXTURE_2D
#      end
      #end
    end
  end

  private
  def x_and_y(*a)
    if a.length == 1 then
      if a[0].kind_of? Array then a[0]
      elsif a[0].kind_of? Fixnum then # just one numeric argument supplied, assume it's an array offset
        [a[0] % image.height, a[0] / image.height]
      else [a[0].x, a[0].y]
      end
    else a
    end
  end
end
