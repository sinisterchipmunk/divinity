class Interface::Containers::Frame < Interface::Components::Component
  include Interface::Containers::Container
  attr_accessor :pinned
  attr_accessor :frame_manager#, :always_on_top, :always_on_bottom
  attr_reader :root_panel, :title_bar
  delegate :remove_all_components, :to => :root_panel
  theme_selection :primary

  alias _add add
  alias frame_layout layout
  alias frame_layout= layout=

  def initialize(*args, &blk)#caption = "Untitled Frame", options = {})#layout = Interface::Layouts::FlowLayout.new)
    options = args.extract_options!
    options.reverse_merge! default_options
    caption = args[0] || "Untitled Frame"
    super()
    @root_panel = Interface::Containers::Panel.new
    self.frame_layout = Interface::Layouts::BorderLayout.new(0,0)
    self.background_visible = true
    self.layout = options[:layout] if options.key? :layout

    @title_bar = Interface::Components::TitleBar.new(caption) if options[:title_bar]
    @pinned = options[:pinned]
    _add(root_panel, "Center")

    self.on :mouse_dragged do |evt| mouse_dragged(evt) end
    if @title_bar
      @title_bar.on :mouse_dragged do |evt| mouse_dragged(evt) end
      _add(@title_bar, "North") if @title_bar
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
    root_panel.layout = l
    root_panel.invalidate
    self.invalidate
  end

  def add(comp, cnst = "")
    root_panel.add(comp, cnst)
    root_panel.invalidate
    self.invalidate
  end

  def remove(comp)
    root_panel.remove(comp)
    root_panel.invalidate
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
