require 'test_helper'

class Vertex3dTest < Test::Unit::TestCase
  def test_valid
    v = Vertex3d.new(0, 1, 2)
    [:x, :y, :z].each { |i| assert_kind_of Numeric, v.send(i) }
    v = Vertex3d.new(5)
    [:x, :y, :z].each { |i| assert_kind_of Numeric, v.send(i) }
    v = Vertex3d.new(Vertex3d.new(0, 1, 2))
    [:x, :y, :z].each { |i| assert_kind_of Numeric, v.send(i) }
  end

  def test_magnitude
    assert_equal 4, Vertex3d.new( 4, 0, 0).magnitude
    assert_equal 4, Vertex3d.new(-4, 0, 0).magnitude
    assert_equal 4, Vertex3d.new( 0, 4, 0).magnitude
    assert_equal 4, Vertex3d.new( 0,-4, 0).magnitude
    assert_equal 4, Vertex3d.new( 0, 0, 4).magnitude
    assert_equal 4, Vertex3d.new( 0, 0,-4).magnitude
    assert_equal Math.sqrt(75), Vertex3d.new( 5, 5, 5).magnitude
    assert_equal Math.sqrt(75), Vertex3d.new(-5,-5,-5).magnitude
  end

  def test_distance
    v1 = Vertex3d.new(-5, -5, 0)
    v2 = Vertex3d.new(5, 5, 0)

    assert_equal Math.sqrt(200), v1.distance(v2)
  end

  def test_cross
    assert_equal Vertex3d.new(1,0,0), Vertex3d.new(0,0,-1).cross(Vertex3d.new(0,1,0))
  end

  def test_normal
    assert Vertex3d.new(5,7,9).normalize.normal?
  end

  def test_scale
    assert_equal Vertex3d.new(1,1,1), Vertex3d.new(0.5, 0.5, 0.5).scale(2)
  end

  def test_magnitude_equality
    assert Vertex3d.new(-5,-5,0).magnitude_equal?(Vertex3d.new(5,5,0))
    assert !Vertex3d.new(-5,-5,0).magnitude_equal?(Vertex3d.new(4,4,0))
  end

  def test_equality
    assert_equal Vertex3d.new(-5, -5, 0), Vertex3d.new(-5, -5, 0)
    assert_not_equal Vertex3d.new(-5, -5, 0), Vertex3d.new(5, 5, 0)
  end
  
  def test_true
    assert true
  end
end