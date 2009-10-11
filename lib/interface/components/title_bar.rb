module Interface
  module Components
    class TitleBar < Component
      def initialize(caption="")
        super()
        @caption = caption
      end
      
      def minimum_size();   Dimension.new(0, 25); end
      def maximum_size();   Dimension.new(0, 25); end
      def preferred_size(); Dimension.new(0, 25); end
      
      def paint
        paint_background
        
        glColor4f(0,0,0,1)
        Font.select.put(12, ((25 - Font.select.height) / 2).to_i, @caption)
        glColor4f(1,1,1,1)
        #TODO: Make title bar display stuff.
      end
    end
  end
end
