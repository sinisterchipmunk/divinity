class Screen::Viewport
  include Gl
  include Geometry
  
  def initialize
    @viewport = [ 0, 0, 0, 0 ]
  end
  
  def update
    @viewport = glGetIntegerv(GL_VIEWPORT)
  end
  
  def x(); update if @viewport[2] == 0 and @viewport[3] == 0; @viewport[0]; end
  def y(); update if @viewport[2] == 0 and @viewport[3] == 0; @viewport[1]; end
  def width(); update if @viewport[2] == 0 and @viewport[3] == 0; @viewport[2]; end
  def height(); update if @viewport[2] == 0 and @viewport[3] == 0; @viewport[3]; end

  def size(); Dimension.new(width(), height()); end
  def bounds(); Geometry::Rectangle.new(x, y, width, height); end
end