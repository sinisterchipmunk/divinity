module MagickExtensions
  def to_gl
    @gl_counterpart ||= Textures::Texture.new(self)
  end

  # really wish we didn't have to rely on external forces for this, but I'm not sure how to hook into any kind of
  # "on_change" methods in Magick. Until then, call this method to regenerate the OpenGL textures when your image
  # changes.
  def invalidate_gl
    @gl_counterpart.free_resources if @gl_counterpart
  end
end
