module Interface
  module Layouts
    class Layout
      def initialize; end
      def minimum_layout_size(cont);   return adjusted_layout_size(cont) { |comp| comp.minimum_size   }; end
      def maximum_layout_size(cont);   return adjusted_layout_size(cont) { |comp| comp.maximum_size   }; end
      def preferred_layout_size(cont); return adjusted_layout_size(cont) { |comp| comp.preferred_size }; end
      def get_constraints(comp); ""; end
        
      def add_layout_component(comp, name=""); raise "Layout::add_layout_component must be overridden"; end
      def layout_container(parent); raise "Layout::layout_container must be overridden"; end
      def remove_layout_component(comp); raise "Layout::remove_layout_component must be overridden"; end
      def remove_all_components; raise "Layout::remove_all_components must be overridden"; end
      def components; raise "Layout::components must be overridden to return all components associated with this Layout"; end

      protected
      def layout_size(cont, &blk); raise "Layout::layout_size must be overridden"; end

      private
      def adjusted_layout_size(cont, &blk)
        layout_size(cont, &blk)
      end
    end
  end
end
