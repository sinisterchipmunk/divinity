class World::Character::Race < Resources::Content
  random_access_attr :favored_class, :speed, :size, :constitution, :charisma, :strength, :intelligence,
                     :dexterity, :wisdom, :feats, :skill_points

  def revert_to_defaults!
    @abilities, @skills, @saving_throws, @attack_bonuses, @armor_class_bonuses, @languages, @bonus_languages =
            [], [], [], [], [], [], []
    @immunities, @proficiencies = [], []

    @validation = { :minimum => { }, :maximum => { } }

    favored_class :any
    speed 30
    size :medium
    constitution 0
    charisma     0
    strength     0
    intelligence 0
    dexterity    0
    wisdom       0
    feats        0
    skill_points 0
  end

  def minimum(options)
    @validation[:minimum].merge! options
  end

  def maximum(options)
    @validation[:maximum].merge! options
  end

  def proficiency(*names)
    options = names.extract_options!
    @proficiencies.concat names.collect { |l| [ l, options ] }
  end

  def immunity(name, options = {})
    @immunities << [ name, options ]
  end

  def ability(name, options = {})
    @abilities << [ name, options ]
  end

  def skill(name, bonus, options = { })
    @skills << [name, bonus, options]
  end

  def saving_throw(bonus, name = :all, options = {})
    bonus, name = name, bonus if name.kind_of? Fixnum and not bonus.kind_of? Fixnum
    @saving_throws << [ name, bonus, options ]
  end

  def attack_bonus(amount, options = {})
    @attack_bonuses << [ amount, options ]
  end

  def armor_class_bonus(amount, options = {})
    @armor_class_bonuses << [ amount, options ]
  end

  def language(*languages)
    options = languages.extract_options!
    @languages.concat languages.collect { |l| [ l, options ] }
  end

  def bonus_languages(*languages)
    options = languages.extract_options!
    @bonus_languages.concat languages.collect { |l| [ l, options ] }
  end
end
