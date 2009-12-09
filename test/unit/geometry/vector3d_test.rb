require 'test_helper'

class Vector3dTest < Test::Unit::TestCase
  def test_valid
    v = Vector3d.new(0, 1, 2)
    [:x, :y, :z].each { |i| assert_kind_of Numeric, v.send(i) }
    v = Vector3d.new(5)
    [:x, :y, :z].each { |i| assert_kind_of Numeric, v.send(i) }
    v = Vector3d.new(Vector3d.new(0, 1, 2))
    [:x, :y, :z].each { |i| assert_kind_of Numeric, v.send(i) }
  end

  def test_division
    v = Vector3d.new(1, 2, 3)
    v /= 2.0
    assert_equal 0.5, v.x
    assert_equal 1, v.y
    assert_equal 1.5, v.z
  end

  def test_magnitude
    assert_equal 4, Vector3d.new( 4, 0, 0).magnitude
    assert_equal 4, Vector3d.new(-4, 0, 0).magnitude
    assert_equal 4, Vector3d.new( 0, 4, 0).magnitude
    assert_equal 4, Vector3d.new( 0,-4, 0).magnitude
    assert_equal 4, Vector3d.new( 0, 0, 4).magnitude
    assert_equal 4, Vector3d.new( 0, 0,-4).magnitude
    assert_equal Math.sqrt(75), Vector3d.new( 5, 5, 5).magnitude
    assert_equal Math.sqrt(75), Vector3d.new(-5,-5,-5).magnitude
  end

  def test_distance
    v1 = Vector3d.new(-5, -5, 0)
    v2 = Vector3d.new(5, 5, 0)

    assert_equal Math.sqrt(200), v1.distance(v2)
  end

  def test_cross
    assert_equal Vector3d.new(1,0,0), Vector3d.new(0,0,-1).cross(Vector3d.new(0,1,0))
  end

  def test_normal
    assert Vector3d.new(5,7,9).normalize.normal?
  end

  def test_scale
    assert_equal Vector3d.new(1,1,1), Vector3d.new(0.5, 0.5, 0.5).scale(2)
  end

  def test_magnitude_equality
    assert Vector3d.new(-5,-5,0).magnitude_equal?(Vector3d.new(5,5,0))
    assert !Vector3d.new(-5,-5,0).magnitude_equal?(Vector3d.new(4,4,0))
  end

  def test_equality
    assert_equal Vector3d.new(-5, -5, 0), Vector3d.new(-5, -5, 0)
    assert_not_equal Vector3d.new(-5, -5, 0), Vector3d.new(5, 5, 0)
  end
  
  def test_true
    assert true
  end
end