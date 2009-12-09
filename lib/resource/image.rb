# TODO: Note that this entire class is going to be replaced by the base Textures::Texture class
# at one point or another; it's only a matter of time.
#
class Resource::Image < Textures::Texture
  include ::Geometry
  include Magick

  attr_reader :image_list, :path, :size

  delegate :width, :height, :to => :size
  delegate :depth, :to => :image_list
  
  @@image_lists = {}

  def initialize(path_or_data)
    if File.file?(path_or_data)
      @path = path_or_data
      # make sure it hasn't already been loaded; if so, copy that data.
      if @@image_lists[@path] then @image_list = @@image_lists[@path]
      else @@image_lists[@path] =  @image_list = ImageList.new(@path)
      end
    else
      if @@image_lists[@path] then @image_list = @@image_lists[@path]
      else @@image_lists[@path] =  @image_list = path_or_data
      end
    end
    @size = Dimension.new(@image_list.columns, @image_list.rows)
  end

  def surface
    @surface ||= SDL::Surface.loadFromString(@image_list.to_blob { self.format = "PNG" })
  end
end
