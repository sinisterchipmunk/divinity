class Textures::TextureGenerator < Textures::Texture
  attr_reader :update_listeners

  @@generated_textures = HashWithIndifferentAccess.new
  def initialize(opt = HashWithIndifferentAccess.new)
    super()
    @surface = nil
    @options = opt
    @update_listeners = []
  end
  
  def options=(opt)
    set_options(opt)
  end
  
  def set_option(s, t)
    if @options[s] != t
      @options[s] = t
      free_resources
      @update_listeners.each do |ul|
        ul.send :texture_options_updated, self if ul.respond_to? :texture_options_updated
      end
    end
  end

  def set_options(options) options.each { |key, value| set_option key, value } end
  
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
      "#{v}-"
    end
    "#{self.class.name.underscore}-#{key.join(".")}".gsub(/[^a-zA-Z0-9\.\-_\[\]\=\+\^\\\/]/, '')
  end

  def generate
    @_generating = true
    define_defaults(@options)
    if not image.nil?
      # should consider not doing this, if we want to keep the cached copy in GL memory
      # note that it's ok right now because we're only keeping the cached *image* in system memory (and not GL memory)
      free_resources
    end
    if @@generated_textures[cache_key]
      self.image = @@generated_textures[cache_key]
    else
#      if File.exist? "data/cache/#{cache_key}.png"
#        self.image = Resources::Image.new("data/cache/#{cache_key}.png").image
#      else
        File.makedirs(File.dirname("data/cache/#{cache_key}.img"))
        do_generation(@options)
#      end
      @@generated_textures[cache_key] = self.image
    end
    @_generating = false
  end

  def save_to_file(fi)
    File.open(fi, "wb") { |f| f.print image.to_blob { self.format = 'PNG' } }
  end

  def load_from_file(fi)
    self.image = Magick::ImageList.new(fi)
  end
  
  protected
  def define_defaults(options); end

  def do_generation(options)
    raise "TextureGenerator::do_generation must be overridden. Should return a Magick::Image."
  end
  
  #def data
  #  self.surface
  #end
  
  def image
    r = super
    if r.nil? and not @_generating
      generate if r.nil?
      return super
    end
    r
  end
end
