class Array
  # Returns an array of integers extracted from the beginning of this array. Probably more efficient than
  # #extract_vector3d!
  def extract_vector3i!
    __extract_vector3i!
#    a = self
#    if false and a.length == 0 then raise "Expected vector coordinates"
#    elsif a.length >= 3 and a[0].kind_of? Numeric and a[1].kind_of? Numeric and a[2].kind_of? Numeric
#      return a.slice!(0, 3)
#    elsif a.length >= 1 and a[0].kind_of? Vertex3d
#      return a.slice!(0, 1).first.to_a[0..2]
#    elsif a.length >= 1 and a[0].kind_of? Array and (a[0].length == 3 or a[0].length == 4)
#      return a.slice!(0, 1).first[0..2]
#    elsif a.length >= 1 and a.first.kind_of? Array and a.first.length == 1 and a.first.first.kind_of? Numeric
#      i = a.slice!(0,1).first.first
#      return [i, i, i]
#    elsif a.length == 1 and a[0].kind_of? Numeric # but a[1] and/or a[2] are not, so it's only 1 number
#      i = a.slice!(0,1).first
#      return [i, i, i]
#    elsif a.length == 0
#      return [0,0,0]
#    end
#    raise "Could not parse vector coordinates out of #{self.inspect}"
  end

  # Returns a Vector3d comprised of either three integers, a Vector3d, a Vertex3d or an array of 3 integers
  # extracted from the beginning of this array. Probably less efficient than #extract_vector3d!
  def extract_vector3d!
    a = self
    if false and a.length == 0 then raise "Expected vector coordinates"
    elsif a.length >= 4 and a[0].kind_of? Numeric and a[1].kind_of? Numeric and a[2].kind_of? Numeric and
            a[3].kind_of? Numeric
      return Vector3d.new(a.slice!(0, 4))
    elsif a.length >= 3 and a[0].kind_of? Numeric and a[1].kind_of? Numeric and a[2].kind_of? Numeric
      return Vector3d.new(a.slice!(0, 3))
    elsif a.length >= 1 and a[0].kind_of? Vertex3d
      return a.slice!(0, 1).first
    elsif a.length >= 1 and a[0].kind_of? Array and (a[0].length == 3 or a[0].length == 4)
      return Vector3d.new(*a.slice!(0, 1).first)
    elsif a.length >= 1 and a.first.kind_of? Array and a.first.length == 1 and a.first.first.kind_of? Numeric
      i = a.slice!(0,1).first.first
      return Vector3d.new(i, i, i)
    elsif a.length == 1 and a[0].kind_of? Numeric # but a[1] and/or a[2] are not, so it's only 1 number
      return Vector3d.new(a.slice!(0, 1).first)
    elsif a.length == 0
      return Vector3d.new(0,0,0)
    end
    raise ArgumentError, "Could not parse vector coordinates out of #{self.inspect}"
  end
end