class Magick::ImageList
  def to_gl
    @gl_counterpart ||= Textures::Texture.new(self)
  end
end
