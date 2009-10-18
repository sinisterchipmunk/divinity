class Interface::Components::ImageSelector < Interface::Components::InputComponent
  attr_reader :edge, :image
  attr_accessor :images, :maintain_aspect_ratio

  def after_initialize(options)
    background_texture.set_option :fill_opacity, 0
    self.edge = true
    self.maintain_aspect_ratio = true

    set_options! options
    @index = (images.include? value) ? images.index(value) : 0

    update_image!
  end

  def next!
    @index += 1
    @index %= images.length
    update_image!
  end

  def previous!
    @index -= 1
    @index %= -images.length
    update_image!
  end

  def paint_background
    glColor4fv [1,1,1,1]
    r = bounds
    iw = r.width
    ih = r.height
    if maintain_aspect_ratio
      maxr = r.width.to_f / r.height.to_f
      imgr = image.width.to_f / image.height.to_f
      if (imgr > maxr)
        ih = image.height.to_f / (image.width.to_f / r.width.to_f)
      else
        iw = image.width.to_f / (image.height.to_f / r.height.to_f)
      end
      ih, iw = ih.floor, iw.floor
    end

    # center image
    ix = (r.width - iw) / 2
    iy = (r.height - ih) / 2

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

  def preferred_size
    Dimension.new(image.width, image.height)
  end

  def update_background_texture
    super
    background_texture.set_options(:background_image => image)
  end

  private
  def update_image!
    self.value = images[@index]
    @image = Resources::Image.new(self.value)
    update_background_texture
  end
end
