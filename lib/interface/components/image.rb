class Interface::Components::Image < Interface::Components::Component
  attr_reader :edge
  attr_accessor :maintain_aspect_ratio

  def initialize(path, options = {}, &block)
    super()
    @path = path
    background_texture.set_option(:fill_opacity, 0)
    self.edge = true
    @image = Resources::Image.new(path)
    @maintain_aspect_ratio = true
    
    options.each { |k,v| self.send("#{k}=", v) }
    yield if block_given?
  end

  def paint
    glColor4fv [1,1,1,1]
    iw = width
    ih = height
    if @maintain_aspect_ratio
      if iw < ih
        # scale height to match width
        r = @image.height.to_f / @image.width.to_f
        ih = (iw * r).floor
      else
        # scale width to match height
        r = @image.width.to_f / @image.height.to_f
        iw = (ih * r).floor
      end
    end

    # center image
    ix = (width - iw) / 2
    iy = (height - ih) / 2

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
