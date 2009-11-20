character_class :rogue do
  description "Rogues have little in common with one another. Some are stealthy thieves. Others are silver-tongued "+
              "tricksters. Still others are scouts, infiltrators, spies, diplomats, or thugs. What they do share "+
              "is versatility, adaptability, and resourcefulness. In general, rogues are skilled at getting what "+
              "others don't want them to get: entrance into a locked treasure vault, safe passage past a deadly "+
              "trap, secret battle plans, a guard's trust, or some random person's pocket money."
  alignment :any
  hit_die :d6
  class_skills :appraise, :balance, :bluff, :climb, :craft, :decipher_script, :diplomacy, :disable_device,
               :disguise, :escape_artist, :forgery, :gather_information, :hide, :intimidate, :jump,
               :knowledge_local, :listen, :move_silently, :open_lock, :perform, :profession, :search,
               :sense_motive, :sleight_of_hand, :spot, :swim, :tumble, :use_magic_device, :use_rope
  skill_points 8 + actor(:player).ability_bonus(:intelligence)
  proficient_with :simple_weapons, :hand_crossbow, :rapier, :sap, :shortbow, :short_sword
  proficient_with :light_armor
  base_attack_bonus :secondary
  primary_saving_throw :reflex
  
  # The difference between Feats and Special Abilities, in terms of mechanics:
  #   Feats are passive, and are triggered automatically at certain points, for instance when attacking
  #   Special abilities are triggered only when the player directly intervenes.
  #
  #  Below, several feats are added more than once (sneak_attack for instance). This causes multiple instances
  #  of that feat to be active at the same time, in effect multiplying the feat's effect by two.
  #  For instance, when the :sneak_attack feat is added, it will trigger 1d6 damage when the conditions are right.
  #  When the :sneak_attack feat is added a second time, it will trigger an additional 1d6 damage for a total of 2d6.
  #
  # Edit: actor.grant_feat and actor.grant_ability have been combined into actor.grant; feats and abilities are two
  # separate things, so there's no reason we can't detect them within #grant instead of forcing two syntaxes.
  #
  # The #grant_one_of method works just like #grant, except that the actor must choose one and only one of the
  # abilities listed. In the case of AI, which item is selected depends entirely on the actor in question - it may
  # choose it at random, or it may select a particular ability based on the actor's definition.

  chosen_special_abilities = [:crippling_strike, :defensive_roll, :improved_evasion, :opportunist, :skill_mastery,
                              :slippery_mind, :feat]
  
  levels do |actor|
    case actor.level
      when 1  then actor.grant :sneak_attack, :trapfinding
      when 2  then actor.grant :evasion
      when 3  then actor.grant :sneak_attack, :trap_sense
      when 4  then actor.grant :uncanny_dodge
      when 5  then actor.grant :sneak_attack
      when 6  then actor.grant :trap_sense
      when 7  then actor.grant :sneak_attack
      when 8  then actor.grant :improved_uncanny_dodge
      when 9  then actor.grant :sneak_attack, :trap_sense
      when 10 then actor.grant_one_of chosen_special_abilities
      when 11 then actor.grant :sneak_attack
      when 12 then actor.grant :trap_sense
      when 13 then actor.grant :sneak_attack and actor.grant_one_of chosen_special_abilities
      when 14
      when 15 then actor.grant :sneak_attack, :trap_sense
      when 16 then actor.grant_one_of chosen_special_abilities
      when 17 then actor.grant :sneak_attack
      when 18 then actor.grant :trap_sense
      when 19 then actor.grant :sneak_attack and actor.grant_one_of chosen_special_abilities
      when 20
    end
  end
end
