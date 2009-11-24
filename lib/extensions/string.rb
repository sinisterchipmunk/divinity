class String
  alias from_hex hex

  def to_rgb
    s = self.downcase
    s = s[1..-1] if s[0] == ?#
    raise ArgumentError, "Not a valid hex RGB value: #{self.inspect}" if s =~ /[^0-9a-z]/
    r, g, b = if s.length == 3
      ["#{s[0].chr}f", "#{s[1].chr}f", "#{s[2].chr}f"]
    elsif s.length == 4 # RGBA: do we ignore alpha, or raise ArgumentError?
      ["#{s[0].chr}f", "#{s[1].chr}f", "#{s[2].chr}f"]#raise ArgumentError, "Expected RGB, found RGBA: #{self.inspect}"
    elsif s.length == 6
      [ s[0..1], s[2..3], s[4..5] ]
    elsif s.length == 8 # RGBA
      [ s[0..1], s[2..3], s[4..5] ]#raise ArgumentError, "Expected RGB, found RGBA: #{self.inspect}"
    else
      raise ArgumentError, "Not a valid hex RGB value: #{self.inspect}"
    end
    [r.hex, g.hex, b.hex]
  end

  def to_rgba
    s = self.downcase
    s = s[1..-1] if s[0] == ?#
    raise ArgumentError, "Not a valid hex RGBA value: #{self.inspect}" if s =~ /[^0-9a-z]/
    r, g, b, a = if s.length == 3 # RGB: do we set alpha to 255, or raise ArgumentError?
      ["#{s[0].chr}f", "#{s[1].chr}f", "#{s[2].chr}f", "ff"]
    elsif s.length == 4
      [ "#{s[0].chr}f", "#{s[1].chr}f", "#{s[2].chr}f", "#{s[3].chr}f" ]
    elsif s.length == 6 # RGB: do we set alpha to 255, or raise ArgumentError?
      [ s[0..1], s[2..3], s[4..5], "ff" ]
    elsif s.length == 8
      [ s[0..1], s[2..3], s[4..5], s[6..7] ]
    else
      raise ArgumentError, "Not a valid hex RGBA value: #{self.inspect}"
    end
    [r.hex, g.hex, b.hex, a.hex]
  end
end
