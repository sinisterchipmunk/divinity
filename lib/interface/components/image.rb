class Interface::Components::Image < Interface::Components::InputComponent
  attr_reader :edge, :image
  attr_accessor :maintain_aspect_ratio

  def after_initialize(options)
    self.edge = true
    self.maintain_aspect_ratio = true
    
    background_texture.set_option(:fill_opacity, 0)
    update_image!

    set_options! options
  end

  def update_image!
    @image = Resources::Image.new(self.value)
    update_background_texture
  end

  def path; self.value; end
  def path=(a); self.value = a; update_image!; end

  def paint_background
    glColor4fv [1,1,1,1]
    rect = bounds.dup
    rect.x = rect.y = 0

    iw = rect.width
    ih = rect.height
    if maintain_aspect_ratio
      maxr = rect.width.to_f / rect.height.to_f
      imgr = image.width.to_f / image.height.to_f
      if (imgr > maxr)
        ih = image.height.to_f / (image.width.to_f / rect.width.to_f)
      else
        iw = image.width.to_f / (image.height.to_f / rect.height.to_f)
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

  def preferred_size
    Dimension.new(image.width, image.height)
  end

  def update_background_texture
    super
    background_texture.set_options(:background_image => image)
  end
end
