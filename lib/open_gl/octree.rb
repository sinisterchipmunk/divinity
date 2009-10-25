class OpenGl::Octree
  MAX_OCTREE_DEPTH = 8

  # When the octree has this many objects in it or more, and its depth is less than MAX_OCTREE_DEPTH, it will attempt
  # to subdivide itself and pass the objects off to its respective children.
  THRESHOLD = 16
  
  class ObjectDescriptor #:nodoc:
    attr_accessor :bounding_box, :up, :right, :view, :size, :position, :object, :octree

    def initialize(object, octree)
      @object = object
      @octree = octree # this is so we can invalidate the octree when the object changes
      buffer!
    end

    def update(delta, scene = nil)
      object.update(delta, scene) if object.respond_to? :update
      
      # if the object's orientatino or size has changed in any way, its bounding box needs to be regenerated. Also,
      # we need to see if the octree is still valid, and invalidate it if it no longer contains the object.
      if position != object.position or right != object.right or view != object.view or up != object.up or
              size != object.size
        # if the octree still contains this position, then there's no reason to invalidate it, because it's still valid.
        octree.invalidate! unless octree.contains? position
        buffer!
      end
    end

    def render
      object.render if octree.cube_visible? bounding_box
    end

    def render_without_frustum_check
      object.render
    end

    # This is likely a CPU-intensive method and should not be called every frame.
    def buffer!
      # We maintain duplicates so that we can check whether the bounding box needs to be regenerated
      @position = object.position.dup
      @right = object.right.dup
      @view = object.view.dup
      @up = object.up.dup
      @size, size = object.size, object.size
      size = Vertex3d.new(size) unless size.kind_of? Vertex3d
      @bounding_box = OpenGl::Frustum.bounding_box(size.x, size.y, size.z, @position, @view, @up, @right)
    end
  end

  attr_reader :objects, :bounding_boxes, :depth, :children, :parent, :engine
  attr_reader :size, :position
  delegate :cube_visible?, :point_visible?, :sphere_visible?, :to => :engine

  def initialize(engine, depth = 0, parent = nil)
    @engine = engine
    @depth = depth
    @parent = parent
    @objects = []
    @children = []
    @position = Vertex3d.new
    @size = Vector3d.new
  end

  # Validates this octree, building children, moving objects to siblings, and/or resizing itself as necessary.
  def validate!
    # potentially generate bounding boxes for each object in this scene; this has to be done during every validation,
    # because the object's transformations might just be what's causing this validation to commence.

    update_boundary!
    subdivide! if children.empty? and objects.length > THRESHOLD and depth < MAX_OCTREE_DEPTH
    delegate_objects!
    children.each { |c| c.validate! }
    @valid = true
  end

  def update(delta, scene = nil)
    validate! unless valid?
    objects.each { |obj| obj.update(delta, scene) }
  end

  def render
    validate! unless valid?
    visibility = cube_visible? @octree_bounding_box
    return unless visibility

    if $DEBUG
      push_attrib(GL_CURRENT_BIT) do
        glColor4f 1,1,0,1
        wireframe do
          render_cube(position, size.x, size.y, size.z)
        end
      end
    end

    if visibility == :partial
      if children.empty? then
        objects.each { |o| o.render }
      else
        children.each { |c| c.render }
      end
    else # full visibility -- no need to continue testing, just render all objects
      objects.each { |o| o.render_without_frustum_check }
    end
  end

  # Marks this octree as invalid, so that it will be validated the next time it is tested.
  # IMPORTANT: Validating the octree is expensive, and should not be done unless registered objects have changed.
  def invalidate!
    @valid = false
  end

  # Returns true if this octree is valid; false if it needs to be validated and potentially resized or subdivided.
  def valid?
    @valid
  end

  # Returns true if this octree lies completely within the visible frustum. If true, then all sublevel tests can
  # be safely skipped and objects rendered, because any objects in this octree must be within the visible frustum.
  def completely_visible?
    validate! unless valid?
  end

  # Returns true if this octree lies completely beyond the visible frustum. If true, then all sublevel tests can
  # be safely skipped and no objects rendered, because any objects in this octree must be outside the visible frustum.
  def completely_hidden?
    validate! unless valid?
  end

  # The objects to be added can be of any type, but must respond to #position, #up, #view, #right, #render! and #size.
  #
  # #size must return either a number (to be treated as a cube of equal proportions) or a Vector3d (to be treated as a
  # box of differing width, depth and height);
  #
  # #position, #up, #right and #view must return either Vertex3d or Vector3d.
  #
  # See OpenGl::Camera for explanations of what these vectors are.
  #
  def add(*objs)
    objects.concat objs.collect { |o| (o.kind_of? ObjectDescriptor) ? o : ObjectDescriptor.new(o, self) }
    invalidate!
    self
  end

  # Removes the specified object(s) from this octree. They may still exist in worldspace, but they will no longer be
  # monitored, updated or rendered by this octree.
  def remove(*objs)
    objects.each { |obj| objects.delete obj if objs.include? obj.object }
    self
  end

  alias << add
  alias >> remove

  # Returns true if this octree contains the specified worldspace point.
  def contains?(v3d)
    [:x, :y, :z].each do |axis|
      p = @position.send axis
      s = @size.send axis
      v = v3d.send axis
      return false unless p - s <= v and p + s >= v
    end
    true
  end

  protected
  attr_writer :position, :size
  
  # This is the first method called from Octree#validate! and is responsible for setting the center point of the octree,
  # as well as calculating its minimum boundaries. It is NOT responsible for setting the positions or sizes of child
  # octrees, because they will set their own dimensions based on the objects that are delegated to them.
  def update_boundary!
    if depth == 0
      # find the centerpoint as well as the maximum x, y, z bounds, based on the bounding box for each object in this
      # octree
      position = Vertex3d.new
      min, max = nil, nil
      objects.each do |obj|
        objpos = obj.position
        position += obj.position
        d = bb_size(obj.bounding_box)
        if min.nil?
          min = position - d
          max = position + d
        else
          min.x, min.y, min.z = min.x.min(objpos.x - d.x), min.y.min(objpos.y - d.y), min.z.min(objpos.z - d.z)
          max.x, max.y, max.z = max.x.max(objpos.x + d.x), max.y.max(objpos.y + d.y), max.z.max(objpos.z + d.z)
        end
      end
      position /= objects.length unless objects.empty?
      if min
        min.x, max.x = max.x, min.x if min.x > max.x
        min.y, max.y = max.y, min.y if min.y > max.y
        min.z, max.z = max.z, min.z if min.z > max.z

        @size = Vector3d.new(max.x-min.x, max.y-min.y, max.z-min.z) / 2.0 # we only want half the total size
      else
        @size = Vector3d.new
      end
      @position = position
    end
    
    @octree_bounding_box = OpenGl::Frustum.bounding_box(@size.x, @size.y, @size.z, @position,
                            Vector3d.new(0,0,-1), Vector3d.new(0,1,0), Vector3d.new(1,0,0))
    self
  end

  # self#validate! calls this when # of objects exceeds threshold AND depth < MAX_OCTREE_DEPTH AND children.empty?
  # This method creates 8 child octrees, then positions and sizes them to their maximum allowed sizes. These sizes
  # are used to delegate objects into the child octrees; after delegation, the octrees will be resized
  # based on the objects they contain.
  def subdivide!
    # need to create 8 children. They will position themselves.
    children.clear
    create_child -1, -1, -1 # TOP    LEFT  REAR
    create_child  1, -1, -1 # TOP    RIGHT REAR
    create_child -1, -1,  1 # TOP    LEFT  FRONT
    create_child  1, -1,  1 # TOP    RIGHT FRONT
    create_child -1,  1, -1 # BOTTOM LEFT  REAR
    create_child  1,  1, -1 # BOTTOM RIGHT REAR
    create_child -1,  1,  1 # BOTTOM LEFT  FRONT
    create_child  1,  1,  1 # BOTTOM RIGHT FRONT
    
    #8.times { children << OpenGl::Octree.new(engine, depth+1, self) }
    self
  end

  # Creates a child at the specified location (all arguments should be either -1 or 1) within this octree, and then
  # sizes it to fill one entire quadrant of this octree.
  def create_child(x, y, z)
    sx, sy, sz = size.x / 2.0, size.y / 2.0, size.z / 2.0
    x,y,z = x*sx+position.x, y*sy+position.y, z*sz+position.z

    ch = OpenGl::Octree.new(engine, depth+1, self)
    ch.position.assign! x, y, z
    ch.size.assign! sx, sy, sz
    children << ch
  end

  # Called by self#validate! after subdividing (where necessary), unless objects.empty?. Objects are sorted based on
  # the quadrant of this octree they appear in. This is based off of position, not size of bounding box. Because of
  # this, it is possible for the borders of this octree to overlap the borders of another after #update_boundary!
  # resizes this octree to accomodate object bounding boxes.
  def delegate_objects!
    objects.each do |obj|
      children.each do |child|
        if child.contains? obj.position
          child << obj
          break
        end
      end
    end
    self
  end

  private
  def bb_size(bb)
    lx, ly, lz = nil, nil, nil
    rx, ry, rz = nil, nil, nil
    bb.each do |v|
      if lx.nil?
        lx, rx = v.x, v.x
        ly, ry = v.y, v.y
        lz, rz = v.z, v.z
      else
        lx, ly, lz = lx.min(v.x), ly.min(v.y), lz.min(v.z)
        rx, ry, rz = rx.max(v.x), ry.max(v.y), rz.max(v.z)
      end
    end
    lx, ly, lz, rx, ry, rz = lx.min(rx), ly.min(ry), lz.min(ry), lx.max(rx), ly.max(ry), lz.max(rz)

    Vector3d.new(rx-lx, ry-ly, rz-lz)
  end
end
