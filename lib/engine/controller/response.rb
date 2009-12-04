class Engine::Controller::Response
  # The Insets of a component represent the buffer region between the bounds of this component and the bounds
  # of its parent. For instance, a Panel which contains a Button would look something like:
  #
  #    +---- PANEL BOUNDS ---------------------------+
  #    |                                             |
  #    |   +--- PANEL INSETS/BUTTON BOUNDS ------+   |
  #    |   |                                     |   |
  #    |   |   + - -(BUTTON INSETS)- - - - - +   |   |
  #    |   |                                     |   |
  #    |   |   |         Click Me!           |   |   |
  #    |   |                                     |   |
  #    |   |   + - - - - - - - - - - - - - - +   |   |
  #    |   |                                     |   |
  #    |   +-------------------------------------+   |
  #    |                                             |
  #    +---------------------------------------------+
  #
  # Note that the button insets above don't really have any effect because a Button object is not capable of containing
  # child objects. However, all components have an Insets object whether it is used or not.
  #
  # Insets have no direct effect on rendering. That is, they do not directly change the location or size of any
  # component's graphics context (image). Instead, they are used more as a stencil or ruler by the Layout, which sets
  # the bounds of all child components. A component may feel free (and is expected) to utilize the entire
  # area described in its bounds.
  #
  # The ultimate purpose of Insets is to allow space between one component and the next. This is purely aesthetic
  # and is generally used to, for instance, draw a border around the edges of a frame. Without insets, you could
  # have no borders, because child elements would be placed directly on top of them. The space provided by insets
  # also has a de-cluttering effect on the interface, and generally results in an easier-to-use GUI. They can also
  # be used to reserve an area of the GUI as "off-limits" -- for example, you could modify the bottom_right insets
  # of a component to make room for a status message that is to be drawn directly to a component.
  #
  # Insets can be altered by the component itself, unlike the component's Bounds, which are set by its parent and
  # so cannot be altered by the component. This is why insets are a field of Engine::Controller::Response, while
  # bounds are a field of Engine::Controller::Request (even though they are delegated by Response for convenience).
  #
  class Insets
    attr_accessor :top_left, :bottom_right

    def initialize(x1, y1, x2, y2)
      @top_left = Geometry::Point.new(x1, y1)
      @bottom_right = Geometry::Point.new(x2, y2)
    end

    def tlx; top_left.x; end
    def tly; top_left.y; end
    def brx; bottom_right.x; end
    def bry; bottom_right.y; end
  end

  attr_accessor :insets, :default_theme
  attr_accessor :preferred_size, :minimum_size, :maximum_size, :request, :view, :redirected_to, :redirected_to_params
  attr_reader :graphics_context, :draw
  delegate :engine, :bounds, :width, :height, :to => :request
  delegate :current_theme, :to => :engine
  delegate :controller, :components, :to => :view

  def initialize()
    @_completed = false
    @preferred_size = Geometry::Dimension.new(64, 64)
    @minimum_size = Geometry::Dimension.new(1, 1)
    @maximum_size = Geometry::Dimension.new(1024, 1024)
    @insets = Insets.new(0, 0, 0, 0)
  end

  def redirect(options)
    controller = options.delete :controller
    action = options.delete :action
    self.redirected_to = { :controller => controller, :action => action }
    self.redirected_to_params = options
  end

  def do_redirect
    # controller has signaled that everything's cleaned up for this request and it's safe to begin the redirection
    controller, action = redirected_to[:controller], redirected_to[:action]
    revt = Events::Redirected.new(self.controller, self.controller.action_name, controller, action)
    if controller == self.controller.controller_path
      # controller hasn't changed, so we're just firing another action.
      self.controller.process(action, :event => revt)
    else
      engine.assume_interface controller, redirected_to_params.merge(:action => action, :event => revt)
    end
  end

  def theme(sel = nil, options = {})
    if sel
      #@theme = frame_manager.theme.select(self.class, frame_manager.theme.select(theme_selection))
      @theme_sel = current_theme.select(sel)

      ## need to apply theme settings to the Draw object. This might be a method of Interface::Theme:
      @theme_sel.apply_to(draw)
    end
    @theme_sel
  end

  def theme=(sel); theme sel; end

  def completed?
    @_completed
  end

  def process
    @_completed = false
    prepare_graphics_context!
    view.process
    finalize_graphics_context!
  rescue ArgumentError => err
    raise unless err.message =~ /nothing to draw/
  ensure
    @_valid = false
    @_completed = true
  end

  def finalize_graphics_context!
    @draw.draw(@graphics_context)
    if theme[:colorization]
      colorize!(theme[:colorization][:color], theme[:colorization][:amount])
    end
  end

  def colorize!(color, amount)
    unless color
      raise ArgumentError, "Could not colorize: no color specified for theme #{current_theme.name}, set #{@theme_sel}"
    end

    unless amount
      raise ArgumentError, "Could not colorize: no amount specified for theme #{current_theme.name}, set #{@theme_sel}"
    end

    amount = [amount,amount,amount,0] unless amount.kind_of? Array
    if amount.inject { |a,b| a + b } > 0
      @graphics_context = @graphics_context.colorize(*([amount, color].flatten))
    end
  end

  def prepare_graphics_context!
    if @graphics_context then
      @graphics_context.resize!(bounds.width, bounds.height)
      @resultant_image.resize! bounds.width, bounds.height
    else
      @graphics_context = Magick::Image.new(bounds.width, bounds.height)
      @resultant_image  = Magick::Image.new(bounds.width, bounds.height)
    end
    @graphics_context.matte_reset!
    @resultant_image.matte_reset!
    @draw = Magick::Draw.new
    theme(default_theme || controller.class.theme)
  end

  # Returns true if this and all subcomponents are valid (do not need their images regenerated)
  def valid?
    return false unless @_valid
    view.components.each do |comp|
      return false unless comp.valid?
    end
    true
  end

  def resultant_image
    unless valid?
      @resultant_image.composite!(@graphics_context, 0, 0, Magick::CopyCompositeOp)
      view.components.each do |child|
        x, y = child.bounds.x, child.bounds.y
        sub_image = child.resultant_image
        @resultant_image.composite!(sub_image, x, y, Magick::OverCompositeOp)
      end
      @resultant_image.to_gl.mipmap = false
      # gl was invalidated when mipmap was set.
      #@resultant_image.invalidate_gl
      @_valid = true
    end
    @resultant_image
  end
end
