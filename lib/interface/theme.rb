# A theme is a customized look and feel for the user interface. It can be highly customized with different
# backgrounds, colors, patterns and styles.
#
# In the Divinity Engine, a Theme is subdivided into groups called Themesets. Each themeset contains all of
# the options that configure a particular type of component. While any arbitrary number of Themes may exist
# and can be swapped in and out at will, the names of themesets are hard-coded into the engine (usually in
# the controllers, but sometimes in the views). Most interfaces will simply use the :primary or :secondary
# themeset; however, components at lower levels (such as Buttons, Text Fields, etc.) will use other themesets
# depending on what they need to display. As an example, the Button will swap between the :inset and :outset
# themesets, depending on whether the button is pressed or released, respectively.
#
# If any themeset is searched for but not found, it will simply default to a plain white-on-black GUI for
# whichever interface requested it. Other interfaces will not be affected by this.
#
# All themesets automatically inherit their attributes from the :default themeset, so this is the first one
# you should define. Note that order of operation is important: if you define a :primary themeset and then
# define a :default after the fact, the :default options will not be inherited.
#
# Also, since the root-level interface always occupies the entire screen, you should make sure the default themeset
# is completely opaque (no background colors or images), otherwise the game interface will overlay the game
# itself and the player won't be able to see anything!
#
# There are several categories options that can be specified for each themeset, and each category has several
# options associated with it:
#   fill            => fill color is a generic default, used as a fallback when other colors can't be found. It
#     color            # is generally used to "fill" the interior of a shape such as a letter, rectangle, etc.
#     opacity
#   stroke          => stroke color is a generic default, used as a fallback when other colors can't be found. It
#     color            # is generally used for the edges of a shape such as a letter, rectangle, etc.
#     opacity
#     width
#   background      => background is usually drawn to the component before anything else.
#     image            # image is a string pointing to a relative filename.
#     color            # color is blended with the resultant background, so use an alpha channel or just "none"
#     effects          # any effects to apply to the background independent of the remainder of the image
#   border          => border defines the shape of the component and draws the edges.
#     style            # valid options: :round_rect, :rectangle
#     color            # If unspecified, the stroke color is used.
#   colorize        => colorization blends the resultant image with a color.
#     color            # the color to blend towards
#     amount           # the amount to blend each channel. A numeric such as 0.5 or an array like [0.5, 0.5, 0.5, 0.5].
#   effects         => any effects to apply to the image. Valid options:
#                      # Effect(:button, :inset)
#                      # Effect(:button, :outset)
#   font
#     color         => the color of the font. If unspecified, the fill color is used.
#     family        => the font family or name, such as "Arial"
#     style         => valid options: italic, oblique, any
#     weight        => boldness of the font; a number between 100 and 800
#     pointsize     => size of the font in points
#     antialias     => whether the font should be antialiased for better blending with the background
#     stretch       => spacing between letters. Valid options:
#                      # "ultraCondensed", "extraCondensed", "condensed", "semiCondensed", "semiExpanded",
#                      # "expanded", "extraExpanded", "ultraExpanded", "any"
#
#
class Interface::Theme < Resources::Content
  class ThemeType < HashWithIndifferentAccess
    def initialize(theme, *a, &b)
      @theme = theme
      super(*a, &b)
    end

    def inherit(*other_sets)
      other_sets.flatten.each do |other_set|
        self.merge! @theme.select(other_set)
      end
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
    
    alias effect effects

    def Effect(*args)
      name, *args = args
      name = name.to_s if name.kind_of? Symbol
      klass = name.kind_of?(String) ? "Interface::Theme::Effects::#{name.camelize}Effect".constantize : name
      klass.new(*args)
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

  def select(type = :default, defaults = ThemeType.new(self))
    type = type.to_s unless type.kind_of? String
    defaults = defaults.reverse_merge @options['default'] if @options['default']

    @options[type] = ThemeType.new(self) if @options[type].nil?
    @options[type].reverse_merge!(defaults)
    @options[type]
  end

  def with_args(options)
    raise ArgumentError, "Expected a hash, got a #{options.class}" unless options.kind_of? Hash
    raise ArgumentError, "Expected hash to contain :type" unless options.keys.include? :type
    select(options.delete(:type), options)
  end
end
