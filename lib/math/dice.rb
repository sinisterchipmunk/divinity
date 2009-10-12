class Math::Dice
  attr_reader :dice, :count, :sides

  def initialize(count, sides)
    @count, @sides = count, sides
    roll!
  end

  def roll!
    @dice = []
    @count.times { @dice << Math::Die.new(@sides) }
    @dice.sort!
    self
  end

  def to_i
    sum = 0
    @dice.each { |d| sum += d.roll }
    sum
  end

  def to_s; to_i.to_s; end

  def best(count = 1)
    count = count.limit @dice.length, 0
    add_to_i @dice[(@dice.length-count)..@dice.length].reverse
  end

  def worst(count = 1)
    count = count.limit @dice.length, 0
    add_to_i @dice[0..count]
  end

  alias highest best
  alias lowest worst
  alias sum to_i

  %W(<= < == > >= * + - /).each do |operator|
    eval "def #{operator}(a) self.to_i #{operator} a end", binding, __FILE__, __LINE__
  end

  private
  def add_to_i(array)
    def array.to_i
      r = 0
      self.each { |x| r += x.to_i }
      r
    end
    array
  end
end
