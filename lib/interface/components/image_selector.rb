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
    iw = insets.width
    ih = insets.height
    if maintain_aspect_ratio
      if iw < ih
        # scale height to match width
        r = image.height.to_f / image.width.to_f
        ih = (iw * r).floor
      else
        # scale width to match height
        r = image.width.to_f / image.height.to_f
        iw = (ih * r).floor
      end
    end

    # center image
    ix = (insets.width - iw) / 2
    iy = (insets.height - ih) / 2

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
