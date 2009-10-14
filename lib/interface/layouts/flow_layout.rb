module Interface
  module Layouts
    class FlowLayout < Layout
      include Geometry
      attr_accessor :align, :hgap, :vgap, :flow
      
      def initialize(flow=:normal, align=:center, hgap=5, vgap=5)
        super()
        raise "Expected flow type :vertical, :horizontal or :normal" unless [:vertical,:horizontal,:normal].include? flow
        @flow = flow
        @align = align
        @hgap = hgap
        @vgap = vgap
      end

      def add_layout_component(comp, name)
      end
    
      def remove_layout_component(comp)
        if cont.children.include? comp
          comp.parent = nil
          cont.children.delete comp
        end
      end

      def remove_all_components
        cont.children.each do |child|
          child.parent = nil
        end
        cont.children.clear
      end
    
      def layout_container(cont)
        children = cont.children
        size = children.length
        insets = cont.insets
        maxwidth = insets.width - (hgap*2)
        x = insets.x
        y = insets.y + vgap
        rowh = 0
        start = 0

        ltr = true #TODO: Make this based on component orientation
        0.upto(size-1) do |i|
          child = children[i]
          if child.visible?
            d = child.preferred_size
            child.size = d
            if (x == insets.x || (x + d.width) <= maxwidth || flow == :horizontal) and flow != :vertical
              x += hgap if x > insets.x
              x += d.width
              rowh = rowh > d.height ? rowh : d.height
            else
              rowh = moveComponents(cont, hgap, y, maxwidth - x, rowh, start, i, ltr)
              x = d.width
              y += vgap + rowh
              rowh = d.height
              start = i
            end
          end
        end
        moveComponents(cont, hgap, y, maxwidth - x, rowh, start, size, ltr)
      end
    
      protected
      def layout_size(parent, &blk)
        dim = Dimension.new
        children = parent.children
        firstVisible = true
        children.each do |child|
          if child.visible?
            d = yield(child)
            dim.height = d.height > dim.height ? d.height : dim.height
            if firstVisible
              firstVisible = false
            else
              dim.width += hgap
            end
            dim.width += d.width
          end
        end
        dim.width += (hgap * 2)
        dim.height += (vgap * 2)
        return dim
      end
      
      private
      def moveComponents(target, x, y, width, height, rowStart, rowEnd, ltr)
        #x += target.border_size
        #y += target.border_size
        #width -= target.border_size
        #height -= target.border_size
        case @align
          when :left then x += ltr ? 0 : width
          when :center then x += (width / 2)
          when :right then x += ltr ? width : 0
          when :leading then ;
          when :trailing then x += width
        end
        
        size = target.children.length
        rowStart.upto(rowEnd-1) do |i|
          break if i > size
          child = target.children[i]
          if child.visible?
            cy = y + ((height - child.bounds.height) / 2)
            if ltr then child.location = Point.new(x, cy);
            else child.location = Point.new(target.bounds.width - x - child.bounds.width, cy);
            end
            x += child.size.width + hgap
          end
        end
        return height
      end
    end
  end
end