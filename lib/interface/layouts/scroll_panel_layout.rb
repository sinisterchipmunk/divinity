class Interface::Layouts::ScrollPanelLayout < Interface::Layouts::Layout
  attr_accessor :hgap, :vgap

  include Geometry

  def initialize(hgap=2, vgap=2)
    super()
    @content = @scroll_east = @scroll_south = nil
    @hgap = hgap
    @vgap = vgap
  end

  def get_constraints(comp)
    case comp
      when @content  then "content"
      when @scroll_east   then "scroll_east"
      when @scroll_south  then "scroll_south"
      else ""
    end
  end

  def add_layout_component(comp, name="")
    name = name.to_s if name.kind_of? Symbol
    @content      = comp if name.downcase == "content"
    @scroll_east  = comp if name.downcase == "scroll_east"
    @scroll_south = comp if name.downcase == "scroll_south"
  end

  def remove_all_components
    @content = @scroll_east = @scroll_south = nil
  end

  def remove_layout_component(comp)
    case comp
      when @content then @content = nil
      when @scroll_south then @scroll_south = nil
      when @scroll_east then @scroll_east = nil
    end
  end

  def layout_container(cont)
    border_size = cont.border_size
    buf = Rectangle.new(border_size, border_size, cont.bounds.width-border_size, cont.bounds.height-border_size)

    if @scroll_south
      b = @scroll_south.preferred_size
      @scroll_south.bounds = Rectangle.new(buf.x, buf.height - b.height, buf.width - buf.x, b.height)
      buf.height -= b.height + @vgap
    end
    if @scroll_east
      b = @scroll_east.preferred_size
      @scroll_east.bounds = Rectangle.new(buf.width - b.width, buf.y, b.width, buf.height - buf.y)
      buf.width -= b.width + @hgap
    end
    if @content
      @content.bounds = Rectangle.new(buf.x, buf.y, buf.width - buf.x, @content.preferred_size.height)#buf.height - buf.y)
    end

    [@content, @scroll_south, @scroll_east].each do |comp|
      raise "No room to lay out component #{comp.inspect} in container #{parent.inspect}" if comp and
              (comp.width == 0 or comp.height == 0)
    end
  end

  protected
  def layout_size(cont, &blk)
    dim = Dimension.new
    if not @scroll_east.nil?
      d = yield(@scroll_east)
      dim.width += d.width + @hgap
      dim.height = max(d.height, dim.height)
    end
    if not @content.nil?
      d = yield(@content)
      dim.width += d.width
      dim.height = max(d.height, dim.height)
    end
    if not @scroll_south.nil?
      d = yield(@scroll_south)
      dim.width = max(d.width, dim.width) + (cont.border_size*2)
      dim.height += d.height + @vgap + (cont.border_size*2)
    end

    dim.width = 64 if dim.width == 0
    dim.height = 64 if dim.height == 0
    return dim
  end

  private
  def max(a, b); a > b ? a : b; end
end
