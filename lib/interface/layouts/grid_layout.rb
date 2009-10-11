class Interface::Layouts::GridLayout < Interface::Layouts::Layout
  include Geometry
  attr_accessor :hgap, :vgap, :minx, :miny

  # FIXME: Shouldn't this belong somewhere else?
  class Array2D < Array
    def [](a)
      x = super
      return x if x
      self[a] = []
    end

    def width; self.length; end
    def height; r = 0; self.each { |a| r = a.length if a.length > r }; r; end
  end

  def initialize(x=0, y=0, options = {})
    @minx, @miny = 1, 1
    @hgap, @vgap = 2, 2
    @grid = Array2D.new
    x.times { |i| y.times { |j| @grid[i][j] = nil }}
    options.each { |k,v| self.send("#{k}=", v) }
  end
  
  def get_constraints(comp)
    @grid.each_with_index { |a, x| a.each_with_index { |c, y| return x, y if c == comp } }
    raise "Component #{comp} has not been added"
  end

  def add_layout_component(comp, constraints)
    x, y = -1, -1
    x, y = constraints if constraints.kind_of? Array
    x, y = constraints.x, constraints.y if constraints.kind_of? Geometry::Point
    raise "Invalid constraints" unless x >= 0 and y >= 0
    @grid[x][y] = comp
  end

  def remove_all_components; end
  
  def layout_container(parent)
    width, height = parent.width - hgap, parent.height - vgap
    gridx, gridy = @grid.width, @grid.height
    gridx = @minx if gridx < @minx
    gridy = @miny if gridy < @miny
    xpix, ypix = width, height
    xpix = width  / gridx unless gridx == 0
    ypix = height / gridy unless gridy == 0
    xpix -= hgap
    ypix -= vgap
    bs = parent.border_size

    @grid.each_with_index do |arr, x|
      arr.each_with_index do |comp, y|
        if comp
          comp.bounds = Geometry::Rectangle.new(x*(xpix+hgap)+hgap+bs, y*(ypix+vgap)+vgap+bs, xpix-bs, ypix-bs)
        end
      end
    end
  end

  def remove_layout_component(comp)
    @grid.each_with_index do |a,x|
      a.each_with_index do |c,y|
        a[y] = nil and return c if c == comp
      end
    end
  end

  protected
  def layout_size(cont, &blk) cont.size; end
end