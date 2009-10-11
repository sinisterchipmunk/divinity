module Interface
  module Containers
    class Panel < Container
      theme_selection :primary

      def initialize(layout=Interface::Layouts::FlowLayout.new, &blk)
        super(layout, &blk)
      end
      
      def paint
        paint_background unless parent.background_visible?
        super
      end
    end
  end
end
