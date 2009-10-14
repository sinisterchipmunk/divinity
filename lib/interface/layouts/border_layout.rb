module Interface
  module Layouts
    class BorderLayout < Layout
      attr_accessor :hgap, :vgap

      include Geometry

      def initialize(hgap=2, vgap=2)
        super()
        @north = @south = @east = @west = @center = nil
        @hgap = hgap
        @vgap = vgap
      end
    
      def get_constraints(comp)
        case comp
          when @north  then "north"
          when @south  then "south"
          when @east   then "east"
          when @west   then "west"
          when @center then "center"
          else ""
        end
      end
    
      def add_layout_component(comp, name="")
        name = name.to_s if name.kind_of? Symbol
        name.downcase!
        valid_constraints = [ "center", "north", "south", "east", "west" ]
        case name
          when *valid_constraints
            ret = self.instance_variable_get("@#{name}")
            self.instance_variable_set("@#{name}", comp)
            ret.parent = nil if ret
            ret
          else
            raise "Invalid constraints: #{name.inspect}; expected one of #{valid_constraints.inspect}"
        end
      end

      def remove_all_components
        [ :center, :north, :south, :east, :west ].each do |a|
          r = add_layout_component(nil, a)
          r.parent = nil if r.respond_to? "parent="
        end
      end
    
      def remove_layout_component(comp)
        case comp
          when @north then @north = nil
          when @south then @south = nil
          when @east then @east = nil
          when @west then @west = nil
          when @center then @center = nil
        end
      end
    
      def layout_container(cont)
        #bool ltr = true  #TODO: Make this do stuff.
        buf = cont.insets.dup
        #buf = Rectangle.new(border_size, border_size, cont.bounds.width-border_size, cont.bounds.height-border_size)

        if @north
          b = @north.preferred_size
          @north.bounds = Rectangle.new(buf.x, buf.y, buf.width - buf.x, b.height)
          buf.y += b.height + @vgap
        end
        if @south
          b = @south.preferred_size
          @south.bounds = Rectangle.new(buf.x, buf.height - b.height, buf.width - buf.x, b.height)
          buf.height -= b.height + @vgap
        end
        if @east
          b = @east.preferred_size
          @east.bounds = Rectangle.new(buf.width - b.width, buf.y, b.width, buf.height - buf.y)
          buf.width -= b.width + @hgap
        end
        if @west
          b = @west.preferred_size
          @west.bounds = Rectangle.new(buf.x, buf.y, b.width, buf.height - buf.y)
          buf.x += b.width + @hgap
        end
        if @center
          @center.bounds = Rectangle.new(buf.x, buf.y, buf.width - buf.x, buf.height - buf.y)
        end

        [@north, @south, @east, @west, @center].each do |comp|
          raise "No room to lay out component #{comp} in container #{cont} (insets #{cont.insets.inspect})" if comp and
                  (comp.bounds.width == 0 or comp.bounds.height == 0)
        end
      end
    
      protected
      def layout_size(cont, &blk)
        dim = Dimension.new
        #bool ltr = true #TODO: Make this work.
        [@east, @west].each do |comp|
          if not comp.nil?
            d = yield(comp)
            dim.width += d.width + @hgap
            dim.height = max(d.height, dim.height)
          end
        end
        if not @center.nil?
          d = yield(@center)
          dim.width += d.width
          dim.height = max(d.height, dim.height)
        end
        [@north, @south].each do |comp|
          if not comp.nil?
            d = yield(comp)
            dim.width = max(d.width, dim.width)# + (cont.border_size*2)
            dim.height += d.height + @vgap# + (cont.border_size*2)
          end
        end
        dim.width = 64 if dim.width == 0
        dim.height = 64 if dim.height == 0
        return dim
      end
      
      private
      def max(a, b); a > b ? a : b; end
    end
  end
end