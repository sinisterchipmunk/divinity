class Interface::Components::ImageButton < Interface::Components::Button
  attr_reader :edge

  def initialize(image_or_path, *unused)
    super("")
    background_texture.set_option(:fill_opacity, 0)
    self.edge = true
    @image = (image_or_path.kind_of? Resources::Image) ? image_or_path : Resources::Image.new(image_or_path)
  end

  def edge=(a)
    @edge = a
    background_texture.set_options(:edge => @edge)
  end

  def preferred_size
    Dimension.new(@image.width, @image.height)
  end

  def update_background_texture
    super
    background_texture.set_options(:background_image => @image) 
  end
end
