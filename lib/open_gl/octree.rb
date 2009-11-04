class OpenGl::Octree
  MAX_OCTREE_DEPTH = 8

  # When the octree has this many objects in it or more, and its depth is less than MAX_OCTREE_DEPTH, it will attempt
  # to subdivide itself and pass the objects off to its respective children.
  THRESHOLD = 8
  
  class ObjectDescriptor #:nodoc:
    attr_accessor :bounding_box, :up, :right, :view, :size, :position, :object, :octree

    def initialize(object, octree)
      @object = object
      @octree = octree # this is so we can invalidate the octree when the object changes
      @bounding_box = []
      @position = Geometry::Vector3d.new
      @right    = Geometry::Vector3d.new
      @up       = Geometry::Vector3d.new
      @view     = Geometry::Vector3d.new
      @size     = Geometry::Vector3d.new
      buffer!
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
    @octree_bounding_box = []
  end

  # Marks this octree as invalid, so that it will be validated the next time it is tested.
  # IMPORTANT: Validating the octree is expensive, and should not be done unless registered objects have changed.
  def invalidate!
    children.clear
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



  protected
  attr_writer :position, :size
end
