# NOTE now that Component maintains its own background and border, it WILL maintain corresponding display
# lists, but WILL NOT maintain a display list for foreground, which individual components must handle
# on their own!
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

      # Can't say with reliable accuracy any more whether width and height refer to bounds or insets.
      # So, delegation removed, reference it directly.
      #delegate :width, :height, :to => :bounds
      
      def initialize(options = {})
        super()
        @bounds = Geometry::Rectangle.new
        @valid = false
        @background_texture = Textures::RoundRectGenerator.new
        @background_texture.update_listeners << self
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
      
      def invalidate()
        @valid = false
        unless parent
          ### this is not providing any noticeable benefit, and is significantly lowering framerate.
          #@list.teardown! if @list
          #@background_texture.free_resources if @background_texture
        end
      end
      
      def validate()
        @valid = true
        @insets = Rectangle.new(3, 3, bounds.width - 6, bounds.height - 6)
        update_background_texture

        # update display list
        if parent
          if @list then @list.rebuild!
          else @list = OpenGL::DisplayList.new { self.render_background }
          end
        end
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
      def valid?; @valid; end
      def invalid?; not @valid; end
      def background_visible?; background_visible; end

      def scissor(*args, &block)
        x, y, w, h, = (if args.length == 0 then screen_bounds.to_a
        elsif args.length == 1
          b = args[0]
          if b.kind_of? Rectangle then b.to_a
          elsif b.kind_of? Array then b
          else [ b, b, b, b ]
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