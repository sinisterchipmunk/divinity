require 'test_helper'

class ArrayTest < Test::Unit::TestCase
  def test_vector3i_raises_on_fail
    assert_raise ArgumentError do [1,2].extract_vector3i! end
  end

  def test_vector3d_raises_on_fail
    assert_raise ArgumentError do [1,2].extract_vector3d! end
  end

  def test_vector3i_accepts_vertex3d
    i3 = (a1 = [ Vertex3d.new(1,2,3,4) ]).extract_vector3i!
    assert_equal [1,2,3], i3
    assert_length 0, a1 
  end

  def test_vector3d_accepts_vector3d
    i3 = (a1 = [ Vertex3d.new(1,2,3,4) ]).extract_vector3d!
    assert_equal Vector3d.new(1,2,3,4), i3
    assert_length 0, a1 
  end

  def test_vector3i_accepts_vector_from_only_three_numbers
    i3 = (a1 = [ 1, 2, 3 ]).extract_vector3i!
    assert_equal [1, 2, 3], i3
    assert_length 0, a1
  end

  def test_vector3i_accepts_vector_from_only_three_numbers
    d3 = (a3 = [ 1, 2, 3 ]).extract_vector3d!
    assert_equal Vertex3d.new(1, 2, 3), d3
    assert_length 0, a3
  end

  def test_vector3i_accepts_vector_from_exactly_four_numbers
    i3 = (a1 = [ 1, 2, 3, 4 ]).extract_vector3i!
    assert_equal [ 1, 2, 3 ], i3
    assert_length 1, a1
  end

  def test_vector3d_accepts_vector_from_exactly_four_numbers
    d3 = (a3 = [ 1, 2, 3, 4 ]).extract_vector3d!
    assert_equal Vertex3d.new([ 1, 2, 3, 4 ]), d3
    assert_length 0, a3
  end
end
