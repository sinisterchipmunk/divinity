# NOTE that it is up to the individual Component implementation to take care of its own display lists!
# Component#paint doesn't do anything, so having Component maintain its own lists, while preferable, would
# lead to errors because Component can't decide whether or not *this* render pass is going to be the same
# as all the others, or if some condition has changed to affect what is going to be rendered (for instance,
# self.background_visible?)
#
# On the flip side, Component can (and does) take care of the display lists for #paint_background, because
# this is something it can rely on without outside interference.
#
# If that was hard to follow, another reason Component can't manage all of its display lists is Container,
# which is a Component that in turn holds other Components. If all of these were maintaining display lists
# of each others', then there'd be big problems, including rendering nested children exponentially greater
# number of times. Since Component has no concept of "children," it would be foolish (not to mention anti-OO)
# to try to write special cases for all of them.
#
module Interface
  module Components
    class Component
      include GUI
      include Gl
      include Geometry
      include Textures
      include Interface::Components::Component::RenderMethods

      attr_reader :valid, :background_texture, :foreground_color, :insets
      attr_accessor :background_visible
      delegate :width, :height, :to => :bounds
      
      def initialize(options = {})
        super()
        @bounds = Geometry::Rectangle.new
        @valid = false
        @background_texture = Textures::RoundRectGenerator.new
        @background_visible = true
        @foreground_color = [ 0, 0, 0, 1 ]
        update_background_texture
        @insets = Rectangle.new
        options.each { |k,v| self.send("#{k}=", v) }
      end

      def update(time)
        return unless enabled?
        cur = size
        min = minimum_size
        invalidate if cur.width < min.width or cur.height < min.height
        validate if not valid
      end

      def theme
        if frame_manager and frame_manager.theme then
          # Allow theme elements with this exact class name (Interface::Whatever) to override the :primary, :etc
          # TODO: Make this support some flavor of inheritance.
          frame_manager.theme.select(self.class, frame_manager.theme.select(theme_selection))
        else HashWithIndifferentAccess.new
        end
      end
      
      def invalidate(); @valid = false; end
      
      def validate()
        @valid = true
        @insets = Rectangle.new(3, 3, width - 3, height - 3)
        update_background_texture
        #@background_list.rebuild! if @background_list
      end

      def theme_selection
        :secondary
      end

      def self.theme_selection(type)
        class_eval "def theme_selection; #{type.inspect}; end"
      end

      def size=(s)
        if s.kind_of? Array then @bounds.width, @bounds.height = s
        elsif s.kind_of? Dimension then @bounds.width, @bounds.height = s.width, s.height
        else raise "Expected an Array or a Dimension"
        end
        self.invalidate
      end

      def location=(l)
        if l.kind_of? Array then @bounds.x, @bounds.y = l
        elsif l.kind_of? Point then @bounds.x, @bounds.y = l.x, l.y
        else raise "Expected an Array or a Point"  
        end
        self.invalidate
      end

      def size(); Dimension.new(@bounds.width, @bounds.height); end
      def location(); Point.new(@bounds.x, @bounds.y); end
      def bounds=(b); @bounds.x = b.x; @bounds.y = b.y; @bounds.width = b.width; @bounds.height = b.height; self.invalidate; end
      def bounds(); @bounds.clone; end

      def contains?(point)
        visible? and
        point.x >= screen_bounds.x && point.x <= screen_bounds.x+screen_bounds.width &&
        point.y >= screen_bounds.y && point.y <= screen_bounds.y+screen_bounds.height
      end

      def font
        Font.select
      end
      
      def minimum_size(); Dimension.new(1,1) end
      def preferred_size(); Dimension.new(64, 64) end
      def maximum_size(); Dimension.new(1024, 1024) end
      def view; @view; end

      def background_visible?; background_visible; end

      def scissor(*args, &block)
        sb = screen_bounds
        x, y, w, h, = (if args.length == 0 then [ sb.x, sb.y, sb.width, sb.height ]
        elsif args.length == 1
          b = args[0]
          if b.kind_of? Rectangle then [ b.x + sb.x, b.y + sb.y, b.width, b.height ]
          elsif b.kind_of? Array then [ b[0] + sb.x, b[1] + sb.y, b[2], b[3] ]
          else [ b+sb.x, b+sb.y, b, b ]
          end
        else
          args
        end)

        # Invert y for GUIness
        # After it's inverted, it'll be at the top-left instead of the bottom-left; height still goes upward
        # so we need to translate it down by adding height.
        # TODO: Should this math be turned into a convenient helper method somewhere?
        y = frame_manager.height - (y + h)
        frame_manager.scissor x, y, w, h, &block
      end
    end
  end
end