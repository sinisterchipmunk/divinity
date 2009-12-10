# A theme is a customized look and feel for the user old. It can be highly customized with different
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
# whichever old requested it. Other interfaces will not be affected by this.
#
# All themesets automatically inherit their attributes from the :default themeset, so this is the first one
# you should define. Note that order of operation is important: if you define a :primary themeset and then
# define a :default after the fact, the :default options will not be inherited.
#
# Also, since the root-level old always occupies the entire screen, you should make sure the default themeset
# is completely opaque (no background colors or images), otherwise the game old will overlay the game
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
class Theme < Resource::Base
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
