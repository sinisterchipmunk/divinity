module Interface
  module Containers
    class Frame < Container
      include Interface::Listeners::MouseListener
      attr_accessor :pinned
      attr_accessor :frame_manager#, :always_on_top, :always_on_bottom
      attr_reader :root_panel, :title_bar
      delegate :remove_all_components, :to => :root_panel
      theme_selection :primary
      
      alias _add add

      def initialize(*args, &blk)#caption = "Untitled Frame", options = {})#layout = Interface::Layouts::FlowLayout.new)
        options = args.extract_options!
        options.reverse_merge! default_options
        caption = args[0] || "Untitled Frame"
        super(Interface::Layouts::BorderLayout.new(0,0))

        self.background_visible = true
        self.layout = options[:layout] if options.key? :layout
        @title_bar = Interface::Components::TitleBar.new(caption) if options[:title_bar]
        @pinned = options[:pinned]

        self.mouse_listeners << self
        if @title_bar
          _add(@title_bar, "North") if @title_bar
          @title_bar.mouse_listeners << self
        end

        process_block &blk if block_given?
      end
      
      def mouse_dragged(evt)
        unless pinned
          bounds = self.bounds.dup
          bounds.x += evt.xrel
          bounds.y += evt.yrel
          self.bounds = bounds
        end
      end
     
      def pack
        self.size = self.layout.preferred_layout_size(self)
        self.invalidate
      end
      
      def layout=(l)
        unless @root_panel
          @root_panel = Interface::Containers::Panel.new(l)
          #@root_panel.background_visible = true
          _add(root_panel, "Center")
        else
          root_panel.layout = l
        end
        root_panel.invalidate
      end
      
      def add(comp, cnst = "")
        root_panel.add(comp, cnst)
        root_panel.invalidate
      end

      def remove(comp)
        root_panel.remove(comp)
        root_panel.invalidate
      end
      
      def paint
        super
      end

      private
      def default_options
      {
        :layout => Interface::Layouts::FlowLayout.new,
        :title_bar => true,
        :pinned => false
      }
      end
    end
  end
end