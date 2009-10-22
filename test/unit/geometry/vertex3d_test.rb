require 'test_helper'

class Vertex3dTest < Test::Unit::TestCase
  def test_magnitude_is_accurate
    assert_equal Vertex3d.new( 4, 0, 0).magnitude, 4
    assert_equal Vertex3d.new(-4, 0, 0).magnitude, 4
    assert_equal Vertex3d.new( 0, 4, 0).magnitude, 4
    assert_equal Vertex3d.new( 0,-4, 0).magnitude, 4
    assert_equal Vertex3d.new( 0, 0, 4).magnitude, 4
    assert_equal Vertex3d.new( 0, 0,-4).magnitude, 4
    assert_equal Vertex3d.new( 5, 5, 5).magnitude, Math.sqrt(75)
    assert_equal Vertex3d.new(-5,-5,-5).magnitude, Math.sqrt(75)
  end

  def test_distance_arguments
    #assert_equal Vertex3d.new(0, 0, 0).distance(Vertex3d.new())
  end
  
  def test_true
    assert true
  end
end