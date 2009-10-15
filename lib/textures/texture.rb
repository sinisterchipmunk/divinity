class Textures::Texture
  include Helpers::RenderHelper
  include Magick
  include ::Geometry
  
  def id
    @id
    #@ids[surface] || -1
  end

  def id=(a)
    @id = a
    #@ids[surface] = a
    #@ids.delete surface if a == -1 or a.nil?
  end
  
  def initialize
    @id = -1
    #@ids = {}
    @bound = false
  end
  
  def bind
    if id.nil? or id == -1
      bpp = surface.format.bpp / 8
      case bpp
        when 3
          if surface.format.Rmask == 0x000000ff then @format = GL_RGB; else @format = GL_BGR; end
        when 4
          if surface.format.Rmask == 0x000000ff then @format = GL_RGBA; else @format = GL_BGRA; end
        else
          raise "Texture is not true color"
      end
      self.id = glGenTextures(1)[0]
      glEnable(GL_TEXTURE_2D)
      glBindTexture(GL_TEXTURE_2D, id)
      glTexImage2D(GL_TEXTURE_2D, 0, bpp, surface.w, surface.h, 0, @format, GL_UNSIGNED_BYTE, surface.pixels)
      gluBuild2DMipmaps(GL_TEXTURE_2D, bpp, surface.w, surface.h, @format, GL_UNSIGNED_BYTE, surface.pixels)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
      glEnable(GL_TEXTURE_2D)
    end
    @bound = id
    glBindTexture(GL_TEXTURE_2D, id)
    if block_given?
      yield
      unbind
    end
  end
  
  def unbind
    #This will get used when multitexturing is eventually implemented
    @bound = false
  end
  
  def coord2f(x, y)
    glTexCoord2f(x, -y)
  end
  
  def bound?
    @bound != false
  end

  # I had to make this public because I don't know whether Ruby deletes textures when garbage collecting.
  # Better safe than sorry. 
  def free_resources
    glDeleteTextures(id) if id and id != -1
    self.id = -1
    @bound = false
  end

  protected

#  #The size of the image, in the form of a Dimension.
#  def size;  raise "Texture::size must be overridden.";  end
#  #The color depth of the image, in bits (32, 24, etc)
#  def color_depth; raise "Texture::color_depth must be overridden."; end
#  #The image data, in the form of a binary string
#  def data; raise "Texture::data must be overridden."; end
#  #The color format for this image, ie GL_RGBA, GL_BGRA, GL_RGB, GL_BGR, etc.
#  def color_format; raise "Texture::color_format must be overridden."; end
#  #The data format for this image, ie GL_UNSIGNED_BYTE
#  def data_format; GL_UNSIGNED_BYTE; end
  def min_filter; GL_LINEAR_MIPMAP_NEAREST; end
  def mag_filter; GL_LINEAR; end
  
  
  def surface
    raise "Texture::surface must be overridden. Should return an SDL_Surface."
  end
end
