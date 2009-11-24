class Interface::Theme < Resources::Content
  class ThemeType < HashWithIndifferentAccess
    def initialize(*a, &b)
      super(*a, &b)
#      border nil
#      stroke nil
#      colorize nil
#      font nil
#      background nil
#      fill nil
#      effects nil
    end

    [:fill, :background, :stroke].each do |f|
      define_method f do |options|
        sub(f).merge! options unless options.nil?
        sub(f)
      end
    end

    def colorize(color, options = { })
      if color.nil?
        color = "#ffffffff"
        options[:amount] = [0, 0, 0, 0]
      end
      unless (options[:amount].kind_of?(Numeric) || options[:amount].kind_of?(Array))
        raise ":amount expected: either an array of numbers between 0 and 1 (representing amount of RGBA), or one number"
      end

      color ||= "#ffffffff"

      self[:colorization] = { :color => color, :amount => options[:amount] }.with_indifferent_access
    end

    def effects(*list)
      self[:effects] = Array.new unless self[:effects].kind_of? Array
      self[:effects] += list.flatten
      self[:effects].delete nil
      self[:effects]
    end

    def font(*options)
      # This may seem like a roundabout way to do this; it's because something about the timing (is it too early?)
      # is causing the engine to hang on Textures::Texture#bind:glGenTextures(1)[0]. There might be a more elegant
      # way to solve the problem (read: "fix it"!) but this works and frankly I'm not motivated to find that way
      # unless it becomes an issue. This workaround is fine by me until it stops working.
      if options.length > 0
        sub(:font).merge! options.extract_options!
      else
        Textures::Font.select(sub(:font))
      end
    end

    def border(style = nil, options = {})
      border = sub(:border)
      (options.merge! style) and (style = nil) if style.kind_of? Hash
      style = border[:style] if style.nil?
      
      border[:style] = style
      border.merge! options
      border
    end

    def apply_to(draw)
      [:stroke, :fill].each do |field|
        sub(field).each do |key, value|
          key = "#{field}_#{key}"
          value = Magick.enumeration_for(key, value)
          if draw.respond_to?(e = "#{key}=") then draw.send(e, value)
          else draw.send(key, value)
          end
        end
      end
      f = sub(:font)
      [:family, :stretch, :style, :weight].each do |i|
        i = "font_#{i}"
        draw.send("font_#{i}=", Magick.enumeration_for(i, f[i])) if f.key?(i)
      end
      draw.pointsize f[:pointsize] if f.key? :pointsize
      draw.text_antialias f[:antialias] if f.key? :antialias
    end

    private
    def sub(name)
      self[name] = HashWithIndifferentAccess.new unless self.key?(name)
      self[name]
    end
  end

  attr_reader :options

  def set(type, options = {}, &block)
    s = self.select(type, options)
    s.instance_eval(&block) if block_given?
  end

  def initialize(id = nil, engine = nil, &block)
    @options = Hash.new
    super(id, engine, &block)
  end

  def select(type = :default, defaults = ThemeType.new)
    type = type.to_s unless type.kind_of? String
    defaults = defaults.reverse_merge @options['default'] if @options['default']

    @options[type] = ThemeType.new if @options[type].nil?
    @options[type].reverse_merge!(defaults)
    @options[type]
  end

  def with_args(options)
    raise ArgumentError, "Expected a hash, got a #{options.class}" unless options.kind_of? Hash
    raise ArgumentError, "Expected hash to contain :type" unless options.keys.include? :type
    select(options.delete(:type), options)
  end
end
