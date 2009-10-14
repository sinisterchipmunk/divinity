module Interface
  module Containers
    class Panel < Container
      theme_selection :primary

      def initialize(layout=Interface::Layouts::FlowLayout.new, &blk)
        super(layout, &blk)
      end
    end
  end
end
