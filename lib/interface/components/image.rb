class Interface::Components::Image < Interface::Components::Component
  attr_reader :edge
  attr_accessor :maintain_aspect_ratio

  def initialize(path, options = {}, &block)
    super()
    self.edge = true
    
    @path = path
    background_texture.set_option(:fill_opacity, 0)
    @image = Resources::Image.new(path)
    @maintain_aspect_ratio = true
    
    options.each { |k,v| self.send("#{k}=", v) }
    yield if block_given?
  end

  def paint_background
    glColor4fv [1,1,1,1]
    rect = bounds.dup
    rect.x = rect.y = 0

    iw = rect.width
    ih = rect.height
    if @maintain_aspect_ratio
      maxr = rect.width.to_f / rect.height.to_f
      imgr = @image.width.to_f / @image.height.to_f
      if (imgr > maxr)
        ih = @image.height.to_f / (@image.width.to_f / rect.width.to_f)
      else
        iw = @image.width.to_f / (@image.height.to_f / rect.height.to_f)
      end
      ih, iw = ih.floor, iw.floor
    end

    # center image
    ix = (rect.width  - iw) / 2
    iy = (rect.height - ih) / 2

    # show it
    background_texture.bind do
      glBegin(GL_QUADS)
        glTexCoord2f(0, 0)
        glVertex2i(ix, iy)
        glTexCoord2f(0, 1)
        glVertex2i(ix, iy+ih)
        glTexCoord2f(1, 1)
        glVertex2i(ix+iw, iy+ih)
        glTexCoord2f(1, 0)
        glVertex2i(ix+iw, iy)
      glEnd
    end
  end

  def edge=(a)
    @edge = a
    background_texture.set_options(:edge => @edge)
  end

  def path
    @path
  end

  def path=(a)
    @path = a
    @image = Resources::Image.new(@path)
    
    update_background_texture
  end

  def preferred_size
    Dimension.new(@image.width, @image.height)
  end

  def minimum_size
    Dimension.new(2, 2)
  end

  def maximum_size
    Dimension.new(1024, 1024)
  end

  def update_background_texture
    super
    background_texture.set_options(:background_image => @image)
  end
end
