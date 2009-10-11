class Textures::TextureGenerator < Textures::Texture
  @@generated_textures = {}
  def initialize(opt = { })
    super()
    @surface = nil
    @options = opt
  end
  
  def options=(opt)
    modified = false
    opt.each do |name, value|
      #do it this way so that any options
      #that are not overridden are not lost
      @options[name] = value
      modified = true
    end
    free_resources if modified
  end
  
  def set_option(s, t)
    if @options[s] != t
      @options[s] = t
      free_resources
    end
  end

  def set_options(options)
    options.each do |key, value|
      set_option key, value
    end
  end
  
  def options; define_defaults(@options); @options; end
  def option(s); define_defaults(@options); @options[s]; end

  def cache_key
    key = @options.sort { |a,b| a[0].to_s <=> b[0].to_s }.collect do |a|
      k,v= a[0],a[1]
      if v.kind_of? Resources::Image
        v = File.basename(v.path)
      else
        v = v.inspect
      end
      "#{k}=#{v}"
    end
    "#{self.class.name.underscore}-#{key.join(".")}".gsub(/[^a-zA-Z0-9\.\-_\[\]\=\+\^\\\/]/, '')[0..200]
  end

  def generate
    define_defaults(@options)
    if not @surface.nil?
      free_resources
    end
    if @@generated_textures[cache_key]
      @surface = @@generated_textures[cache_key]
#    elsif File.exist? "data/cache/#{cache_key}.img"
#      @surface = @@generated_textures[cache_key] = surface_from_file("data/cache/#{cache_key}.img")
    elsif File.exist? "data/cache/#{cache_key}.png"
      @surface = @@generated_textures[cache_key] = Resources::Image.new("data/cache/#{cache_key}.png").surface
    else
      File.makedirs(File.dirname("data/cache/#{cache_key}.img"))
      @surface = @@generated_textures[cache_key] = do_generation(@options)
#      save_to_file("data/cache/#{cache_key}.img")
    end
  end

  def save_to_file(fi)
    pixels = surface.pixels
    width, height, depth, pitch = surface.w, surface.h, surface.format.bytes_per_pixel*8, surface.pitch
    rmask, gmask, bmask, amask = surface.format.Rmask, surface.format.Gmask, surface.Bmask, surface.format.Amask

    data = [ pixels, width, height, depth, pitch, rmask, gmask, bmask, amask ]
    File.open(fi, "wb") { |f| f.print data.pack("biiiiIIII") }
#    SDL_CreateRGBSurfaceFrom(void *pixels,
#                        int width, int height, int depth, int pitch,
#                        Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, Uint32 Amask
  end

  def surface_from_file(fi)
    data = (File.open(fi, "rb").read.unpack("biiiiIIII"))
    puts data
    SDL::Surface.new_from(*data)
  end
  
  def bind
    self.surface #Generate surface if necessary
    super
  end
  
  protected
  def define_defaults(options); end

  def do_generation(options)
    raise "TextureGenerator::do_generation must be overridden. Should return an SDL_Surface."
  end
  
  def free_resources
    super
    #SDL::FreeSurface(@surface)
    @surface = nil
  end
  
  #def data
  #  self.surface
  #end
  
  def surface
    if @options[:auto_generate] == false and @surface.nil?
      raise "Texture hasn't been generated yet"
    end
    if @surface.nil? then generate; else @surface; end
  end
end