class Fixnum
  def squared
    self ** 2
  end
  
  def xor(b)
    a = self
    a_ = 255 - a
    b_ = 255 - b
    (a & b_) | (a_ & b)
  end
  
  def bytes(a = self)
    r = [ a % 256 ]
    while a > 255
      a = (a / 256).to_i
      r <<= a % 256
    end
    r
  end
  
  def xnor(b)
    255 - xor(b)
  end
  
  def to_x(a = self)
    i = a & 15
    a >>= 4
    r = "#{(0..9).to_a.concat(('a'..'f').to_a)[i]}"
    r = "#{a.to_x}#{r}" if a > 0
    r
  end

  def max(a)
    self > a ? self : a
  end

  def min(a)
    self < a ? self : a
  end
end
