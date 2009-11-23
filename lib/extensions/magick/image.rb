class Magick::Image
  def to_gl
    @gl_counterpart ||= Textures::Texture.new(self)
  end
end
