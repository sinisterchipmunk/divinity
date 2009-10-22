module Bytes
  def bytes(a = self)
    upper, lower = a.divmod(256)
    upper = upper.bytes if upper >= 256
    [upper, lower].flatten
  end
end
