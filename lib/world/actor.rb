class World::Actor
  include Helpers::AttributeHelper
  SEXES = [ :male, :female ]
  ATTRIBUTES = [ :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma ]

  random_access_attr :name, :id, :sex, :race
  random_access_attr *ATTRIBUTES

  def initialize(id, &block)
    @id, @name = id, id.to_s.titleize
    @sex = :male

    reroll_attributes!
    yield_with_or_without_scope(&block) if block_given?
  end

  def validate # callback fires whenever random_access_attr changes something
    # attributes are assigned a text value when they come in from text_field; convert them to ints
    ATTRIBUTES.each do |a|
      self.send("#{a}=", self.send(a).to_i) unless self.send(a).kind_of? Fixnum
    end
  end

  def character_classes(which = nil)
    return @character_classes if which.nil?
    which = { which => 1 } unless which.kind_of? Hash
    @character_classes ||= {}
    @character_classes.merge! which
    # would probably fire something here to check for level-up / level-down
  end

  def attributes
    ATTRIBUTES.collect { |a| self.send(a) }
  end

  def attributes=(arr)
    ATTRIBUTES.each_with_index { |a, i| self.send("#{a}=", arr[i]) }
  end

  def ability_bonus(i)
    (self.send(i) - 10) / 2
  end

  def reroll_attributes!
    ATTRIBUTES.each do |a|
      self.send("#{a}=", 4.d6.best(3).to_i)
    end
  end
end
