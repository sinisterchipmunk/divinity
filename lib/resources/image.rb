class Resources::Image < Textures::Texture
  include ::Geometry
  include Magick

  attr_reader :size, :image_list, :path
  delegate :width, :height, :to => :size

  @@image_lists = {}

  def initialize(path)
    @path = path
    # make sure it hasn't already been loaded; if so, copy that data.
    if @@image_lists[path] then @image_list = @@image_lists[path]
    else @@image_lists[path] =  @image_list = ImageList.new(path)
    end
    @size = Dimension.new(@image_list.columns, @image_list.rows)
  end

  def surface
    SDL::Surface.loadFromString(@image_list.to_blob { self.format = "PNG" })
  end
end
