class Math::Die
  attr_reader :sides, :roll
  def initialize(sides) @sides = sides; reroll; end
  def reroll; @roll = rand(self.sides)+1; end
  def <=>(die); self.roll <=> die.roll; end
  def to_i; self.roll; end
  def to_s; to_i; end
end
