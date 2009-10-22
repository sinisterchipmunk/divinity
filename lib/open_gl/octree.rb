class OpenGl::Octree
  def initialize()
    
  end

  # Returns true if this octree lies completely within the visible frustum. If true, then all sublevel tests can
  # be safely skipped and objects rendered, because any objects in this octree must be within the visible frustum.
  def completely_visible?
    
  end

  # Returns true if this octree lies completely beyond the visible frustum. If true, then all sublevel tests can
  # be safely skipped and no objects rendered, because any objects in this octree must be outside the visible frustum.
  def completely_hidden?
    
  end

  # The objects to be added can be of any type, but must respond to #position, #up, #view, #render! and #size. #size
  # must return either a number (to be treated as a cube of equal proportions) or a Vector3d (to be treated as a cube
  # of differing width, depth and height); #position must return a Vertex3d; #up and #view must return Vector3d's.
  # See OpenGl::Camera for explanations of what these vectors are.
  #
  # HOW I EXPECT THIS TO WORK:
  # Each object should have the above direction vectors, or more ideally a Camera object that represents the object's
  # direction (and delegation of those vector methods into Camera). With those vectors, size of cube seems (at this
  # early stage) to be a simple process:
  #   1. Get the right, view, and up vectors. They should already be normalized.
  #   2. Create a negative copy of each so that we have left, rear and down vectors.
  #   3. Get the width, height and depth W, H and D of the object. Divide each of these by 2.
  #   4. Multiplying the resultant scalars against the vectors above should give points at the extents of each vector
  #      directly relative to the provided sizes, in the object's local coordinates.
  #   5. The resultant view vector will respresent the furthest extent forward this object is expected to reach; using
  #      that as the origin, translate along the left vector by w/2 units until the furthest extent left is reached;
  #      this is the front-left corner. Translate along the up and down vectors for front-left-top and
  #      front-left-bottom. Repeat this process for front-right, rear-left and rear-right for a total of 8 points.
  #   6. If any of these 8 points are visible, return true. Otherwise, return false.
  def add(*objects)
    
  end

  # see #add
  def <<(*objects)
    add *objects
    self
  end
end
