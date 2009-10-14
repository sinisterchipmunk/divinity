class Interface::Layouts::GridLayout < Interface::Layouts::Layout
  include Geometry
  attr_accessor :hgap, :vgap

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

    raise "Invalid constraints" unless constraint_valid?(x) and constraint_valid?(y)
    xs, ys = [], []
    if x.kind_of? Fixnum then xs << x
    else xs.concat [x.first, x.last] # The spaces in between will be filled in automatically - this way is faster
    end
    if y.kind_of? Fixnum then ys << y
    else ys.concat [y.first, y.last]
    end

    xs.each do |x|
      ys.each do |y|
        @grid[x][y] = comp
      end
    end
  end

  def remove_all_components; end
  
  def layout_container(parent)
    insets = parent.insets
    width, height = insets.width - hgap, insets.height - vgap
    gridx, gridy = @grid.width, @grid.height
    xpix, ypix = width, height
    xpix = width  / gridx unless gridx == 0
    ypix = height / gridy unless gridy == 0
    xpix -= hgap
    ypix -= vgap
    #bs = parent.border_size
    previous = []

    @grid.each_with_index do |arr, x|
      arr.each_with_index do |comp, y|
        if comp
          b = Geometry::Rectangle.new(x*(xpix+hgap)+hgap+insets.x, y*(ypix+vgap)+vgap+insets.y, xpix, ypix)
          if previous.include? comp
            comp.bounds = comp.bounds.union! b
          else
            comp.bounds = b
            previous << comp
          end
        end
      end
    end

    previous.each do |comp|
      raise "No room to lay out component #{comp.class} in container #{parent.class}" if comp and
              (comp.width == 0 or comp.height == 0)
    end
  end

  def remove_layout_component(comp)
    @grid.each_with_index do |a,x|
      a.each_with_index do |c,y|
        a[y] = nil if c == comp
      end
    end
    comp
  end

  protected
  def layout_size(cont, &blk)
    largest = nil
    lx, ly = 0, 0
    @grid.each_with_index do |arr, x|
      lx = x if x > lx
      arr.each_with_index do |comp, y|
        ly = y if y > ly
        if comp
          cur = yield(comp)
          largest = cur if largest.nil?
          largest.width = cur.width if largest.width < cur.width
          largest.height = cur.height if largest.height < cur.height
        end
      end
    end
    lx += 1
    ly += 1
    largest.width = largest.width * lx + hgap * (lx-1)
    largest.height = largest.height * ly + vgap * (ly-1)
    largest
  end

  def constraint_valid?(i)
    if i.kind_of? Fixnum
      return i >= 0
    elsif i.kind_of? Range
      return i.first >= 0 && i.last >= 0
    end
    false
  end
end