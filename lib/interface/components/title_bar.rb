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
        Font.select.put(12, ((insets.height - Font.select.height) / 2).to_i, @caption)
        #TODO: Make title bar display stuff.
      end
    end
  end
end
