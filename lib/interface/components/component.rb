module Interface
  module Components
    class Component
      include GUI
      include Gl
      include Geometry
      include Textures

      attr_reader :valid, :background_texture, :border_size
      delegate :x, :y, :width, :height, :to => :bounds
      
      def initialize(options = {})
        super()
        @bounds = Geometry::Rectangle.new
        @valid = false
        @background_texture = Textures::RoundRectGenerator.new
        @border_size = 3
        @background_visible = true
        update_background_texture

        options.each { |k,v| self.send("#{k}=", v) }
      end

      def theme
        if frame_manager and frame_manager.theme then
          # Allow theme elements with this exact class name (Interface::Whatever) to override the :primary, :etc
          # TODO: Make this support some flavor of inheritance.
          frame_manager.theme.select(self.class, frame_manager.theme.select(theme_selection))
        else HashWithIndifferentAccess.new
        end
      end

      def background_visible=(a)
        @background_visible = a
      end
      
      def invalidate(); @valid = false; end
      def validate()
        @valid = true
        update_background_texture
      end

      def theme_selection
        :secondary
      end

      def self.theme_selection(type)
        class_eval "def theme_selection; #{type.inspect}; end"
      end

      def update_background_texture
        background_texture.set_options theme
        background_texture.set_option(:raise_size, border_size)
        background_texture.set_option(:width,  self.bounds.width)
        background_texture.set_option(:height, self.bounds.height)
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

      def border_size=(a); @border_size = a; self.invalidate; end
      def size(); Dimension.new(@bounds.width, @bounds.height); end
      def location(); Point.new(@bounds.x, @bounds.y); end
      def bounds=(b); @bounds.x = b.x; @bounds.y = b.y; @bounds.width = b.width; @bounds.height = b.height; self.invalidate; end
      def bounds(); @bounds.clone; end

      def contains?(point)
        visible? and
        point.x >= screen_bounds.x && point.x <= screen_bounds.x+screen_bounds.width &&
        point.y >= screen_bounds.y && point.y <= screen_bounds.y+screen_bounds.height
      end
    
      def update(time)
        return unless enabled?
        cur = size
        min = minimum_size
        invalidate if cur.width < min.width or cur.height < min.height
        validate if not valid
      end
    
      def render
        return unless visible?
        b = bounds
        glTranslated( b.x,  b.y, 0)
        #scissor b.x, frame_manager.height - b.y - b.height, b.width+3, b.height+1 do
          paint
        #end
        glTranslated(-b.x, -b.y, 0)
      end
      
      def minimum_size(); raise "Component::minimum_size must be overridden"; end
      def preferred_size(); raise "Component::preferred_size must be overridden"; end
      def maximum_size(); raise "Component::maximum_size must be overridden"; end
      def view; @view; end

      def background_visible?; @background_visible; end
      
      protected
      #must be explicitly called
      def paint_background
        return unless background_visible?
        background_texture.bind do
          glBegin(GL_QUADS)
            background_texture.coord2f(0, 0); glVertex2i(0, 0)
            background_texture.coord2f(0, 1); glVertex2i(0, bounds.height)
            background_texture.coord2f(1, 1); glVertex2i(bounds.width, bounds.height)
            background_texture.coord2f(1, 0); glVertex2i(bounds.width, 0)
          glEnd
        end
      end
      
      def paint(); raise "Component::paint must be overridden"; end
    end
  end
end