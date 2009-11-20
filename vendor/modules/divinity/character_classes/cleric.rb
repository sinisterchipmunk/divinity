character_class :cleric do
  description "The handiwork of the gods is everywhere -- in places of natural beauty, in might crusades, "+
              "in soaring temples, and in the hearts of worshipers. Like people, gods run the gamut from "+
              "benevolent to malicious, reserved to intrusive, simple to inscrutable. The gods, however, "+
              "work mostly through intermediaries -- their clerics. Good clerics heal, protect, and aveng. "+
              "Evil clerics pillage, destroy, and sabotage. A cleric uses the power of his god to make the "+
              "god's will manifest. And if a cleric uses his god's power to improve his own lot, that's to "+
              "be expected, too."
  
  alignment :deity, :distance => :one_step
  hit_die :d8
  class_skills :concentration, :craft, :diplomacy, :heal, :knowledge, :profession, :spellcraft
  skill_points 2 + actor(:player).ability_bonus(:intelligence)
  proficient_with :simple_weapons, :armor, :shields # adds all simple weapons, all armor, all shields
  not_proficient_with :tower_shields # removes tower shields (after they were added by the above line)
  bonus_languages :celestial, :abyssal, :infernal
  primary_saving_throw :fortitude, :will
  base_attack_bonus :secondary # BAB starts at 0 and ends at 15

  # spells_per_day array always starts with level 0
  # hash notation { 0 => 1, 1 => 2, . . . } also valid; will be merged with pre-existing values
  levels do |actor|
    case actor.level
      when  1 then actor.grant :turn_or_rebuke_undead
                   actor.spells_per_day = [ 3, 2 ]
                   actor.grant :domain_spell, :level => 1
      when  2 then actor.spells_per_day = [ 4, 3 ]
      when  3 then actor.spells_per_day = [ 4, 3, 2 ]
                   actor.grant :domain_spell, :level => 2
      when  4 then actor.spells_per_day = [ 5, 4, 3 ]
      when  5 then actor.spells_per_day = [ 5, 4, 3, 2 ]
                   actor.grant :domain_spell, :level => 3
      when  6 then actor.spells_per_day = [ 5, 4, 4, 3 ]
      when  7 then actor.spells_per_day = [ 6, 5, 4, 3, 2 ]
                   actor.grant :domain_spell, :level => 4
      when  8 then actor.spells_per_day = [ 6, 5, 4, 4, 3 ]
      when  9 then actor.spells_per_day = [ 6, 5, 5, 4, 3, 2 ]
                   actor.grant :domain_spell, :level => 5
      when 10 then actor.spells_per_day = [ 6, 5, 5, 4, 4, 3 ]
      when 11 then actor.spells_per_day = [ 6, 6, 5, 5, 4, 3, 2 ]
                   actor.grant :domain_spell, :level => 6
      when 12 then actor.spells_per_day = [ 6, 6, 5, 5, 4, 4, 3 ]
      when 13 then actor.spells_per_day = [ 6, 6, 6, 5, 5, 4, 3, 2 ]
                   actor.grant :domain_spell, :level => 7
      when 14 then actor.spells_per_day = [ 6, 6, 6, 5, 5, 4, 4, 3 ]
      when 15 then actor.spells_per_day = [ 6, 6, 6, 6, 5, 5, 4, 3, 2 ]
                   actor.grant :domain_spell, :level => 8
      when 16 then actor.spells_per_day = [ 6, 6, 6, 6, 5, 5, 4, 4, 3 ]
      when 17 then actor.spells_per_day = [ 6, 6, 6, 6, 6, 5, 5, 4, 3, 2 ]
                   actor.grant :domain_spell, :level => 9
      when 18 then actor.spells_per_day = [ 6, 6, 6, 6, 6, 5, 5, 4, 4, 3 ]
      when 19 then actor.spells_per_day = [ 6, 6, 6, 6, 6, 6, 5, 5, 4, 4 ]
      when 20 then actor.spells_per_day = [ 6, 6, 6, 6, 6, 6, 5, 5, 5, 5 ]
    end
  end
end
