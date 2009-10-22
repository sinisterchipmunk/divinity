require 'test_helper'

class FixnumTest < Test::Unit::TestCase
  def test_squared
    i = 5
    assert_equal 25, i.squared
  end

  def test_xor
    i, j = 5, 10
    assert_equal 15, i.xor(j)
    assert_equal 15, j.xor(i)
  end

  def test_xnor
    i, j = 5, 10
    assert_equal 240, i.xnor(j)
    assert_equal 240, j.xnor(i)
  end

  def test_bytes
    assert_equal [255, 255, 255, 255], ((65536*65536)-1).bytes
  end

  def test_hex
    assert_equal "ffffff", 16777215.hex
  end

  def test_max
    assert_equal 5, 4.max(5)
    assert_equal 5, 5.max(4)
  end

  def test_min
    assert_equal 4, 4.min(5)
    assert_equal 4, 5.min(4)
  end

  def test_as_dice
    @i = 2
    [ 2, 3, 4, 6, 8, 10, 12, 20, 100 ].each do |sides|
      dice = @i.send("d#{sides}")
      assert_equal sides, dice.sides
      assert_equal @i, dice.count
      assert_le dice.to_i, @i * sides
      assert_ge dice.to_i, 1
    end
  end
end