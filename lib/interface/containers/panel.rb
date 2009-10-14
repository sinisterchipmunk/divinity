module Interface
  module Containers
    class Panel < Container
      theme_selection :primary

      def initialize(layout=Interface::Layouts::FlowLayout.new, &blk)
        super(layout, &blk)
        self.background_visible = false
      end
    end
  end
end
