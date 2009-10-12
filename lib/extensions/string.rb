class String
  def from_x(val = self)
    hex = ('0'..'9').to_a.concat(('a'..'f').to_a)
    val = val[1..val.length] if val[0].chr == '#'
    r = 0
    0.upto(val.length-1) do |i|
      ch = val[i].chr.downcase
      found = false
      0.upto 15 do |j|
        x = hex[j]
        (r += j and found = true) if x == ch
      end
      raise "Cannot convert character '#{ch}' from hex" if not found
      r <<= 4 if i != val.length-1
    end
    r
  end
end