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
      if v.kind_of? Resource::Image
        v = File.basename(v.path)
      else
        v = v.inspect
      end
      "#{v}-"
    end
    Digest::MD5.hexdigest("#{self.class.name.underscore}-#{key.join(".")}")
  end

  def generate
    @_generating = true
    @options.reverse_merge! default_options
    if not image.nil?
      # should consider not doing this, if we want to keep the cached copy in GL memory
      # (which we're not yet doing)
      free_resources
    end
    File.makedirs(File.dirname("tmp/cache/#{cache_key}.img"))
    do_generation(@options)
    @_generating = false
  end

  def save_to_file(fi)
    File.open(fi, "wb") { |f| f.print image.to_blob { self.format = 'PNG' } }
  end

  def load_from_file(fi)
    self.image = Magick::ImageList.new(fi)
  end
  
  protected
  def default_options; end

  def do_generation(options)
    raise "TextureGenerator::do_generation must be overridden. Should return a Magick::Image."
  end
  
  #def data
  #  self.surface
  #end
  
  def image
    r = super
    if r.nil? and not @_generating
      generate
      return super
    end
    r
  end
end
