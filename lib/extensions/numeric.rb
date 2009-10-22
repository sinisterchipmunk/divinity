class Numeric
  def squared
    self ** 2
  end

  def max(a)
    self > a ? self : a
  end

  def min(a)
    self < a ? self : a
  end
end