class OpenGl::Octree
  MAX_OCTREE_DEPTH = 8

  # When the octree has this many objects in it or more, and its depth is less than MAX_OCTREE_DEPTH, it will attempt
  # to subdivide itself and pass the objects off to its respective children.
  THRESHOLD = 16
  
  attr_reader :objects, :bounding_boxes, :depth, :children, :parent

  def initialize(depth = 0, parent = nil)
    @parent = parent
    @objects = []
    @bounding_boxes = []
    @children = []
  end

  # Validates this octree, building children, moving objects to siblings, and/or resizing itself as necessary.
  def validate!
    subdivide! if children.empty? and objects.length > THRESHOLD and depth < MAX_OCTREE_DEPTH
    delegate_objects! unless objects.empty?
    children.each { |c| c.validate! }
    update_boundary!
    @valid = true
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
  def add(*objects)
    self.objects.concat objects
    self.bounding_boxes.concat objects.collect { |obj| generate_bounding_box_for obj }
    invalidate!
    self
  end

  alias << add

  protected
  # The last step in self#validate!, this method will check the boundaries of this Octree against the positions and
  # edges of each object and each child octree, resizing itself where necessary. If resizing would overstep the bounds
  # of a sibling octree, then resizing does not happen (an octree can't share space with a sibling).
  def update_boundary!

  end

  # self#validate! calls this when # of objects exceeds threshold AND depth < MAX_OCTREE_DEPTH AND children.empty?
  def subdivide!
    # need to create 8 children and position them where needed
  end

  # Called by self#validate! after subdividing (where necessary), unless objects.empty?
  def delegate_objects!
    
  end

  # This is likely a CPU-intensive method and should not be called every frame.
  def generate_bounding_box_for(obj)
    size = obj.size
    size = Vertex3d.new(size) unless size.kind_of? Vertex3d
    frustum.bounding_box(size, obj.position, obj.view, obj.up, obj.right)
  end
end
