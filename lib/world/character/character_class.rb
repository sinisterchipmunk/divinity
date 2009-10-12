class World::Character::CharacterClass < Resources::Content
  random_access_attr :hit_die, :class_skills, :skill_points, :base_attack_type

  def revert_to_defaults!
    name id.to_s.titleize
    base_attack_type :primary
    hit_die :d6
    @alignments = []
    @primary_saving_throws = []
    @proficient_with = []
    @level_blocks = []
  end

  def levels(&block)
    @level_blocks << block if block_given?
  end

  def proficient_with(*items)
    @proficient_with.concat items
  end

  def alignment(which, options = {})
    @alignments << [ which, options ]
  end

  def primary_saving_throw(*throws)
    @primary_saving_throws.concat throws
  end


  def saving_throw_at(throw, level)
    if primary_saving_throw.include? throw then primary_saving_throw_at level
    else secondary_saving_throw_at level
    end
  end

  def primary_saving_throw_at(level)
    (level / 2) + 2 # starts at 2, ends at 12
  end

  def secondary_saving_throw_at(level)
    level / 3 # starts at 0, ends at 6
  end

  def base_attack_bonus_at(level)
    b = base_attack_type
    case b
      when :primary   then level
      when :secondary then (level * 0.75).floor
      when :tertiary  then (level * 0.5).floor
      else raise "Expected base_attack_type to be one of [:primary, :secondary, :tertiary]; found #{b.inspect}"
    end
  end
end
