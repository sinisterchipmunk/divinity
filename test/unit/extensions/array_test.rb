require 'test_helper'

class ArrayTest < Test::Unit::TestCase
  def test_accepts_vector_from_only_three_numbers
    @arr = [ 1, 2, 3 ]
    i3 = @arr.dup.extract_vector3i!
    i4 = @arr.dup.extract_vector4i!
    i4b= [1, 2, 3, 4].extract_vector4i!
    d3 = @arr.dup.extract_vector3d!

    assert i3 == [1, 2, 3]
    assert i4 == [1, 2, 3]
    assert d3.to_a == [1, 2, 3]
    assert i4b == [1, 2, 3, 4]

    @arr.extract_vector3d!
    assert @arr.length == 0
  end
end
