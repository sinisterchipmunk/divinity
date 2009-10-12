race :gnome do
  constitution 2
  strength -2
  size :small
  speed 20
  ability :low_light_vision
  saving_throw 2, :illusion
  saving_throw -1, :illusion, :vs => :gnomes
  attack_bonus 1, :vs => [ :kobolds, :goblins]
  armor_class_bonus 4, :vs => :giants
  skill :listen, 2
  skill :craft, 2, :subtype => :alchemy
  language :common, :gnome
  bonus_languages :draconic, :dwarven, :elven, :giant, :goblin, :orc
  ability :speak_with_animals, :per_day => 1
  ability :dancing_lights,     :per_day => 1, :prerequisite => { :charisma => 10 }
  ability :ghost_sound,        :per_day => 1, :prerequisite => { :charisma => 10 }
  ability :prestidigitation,   :per_day => 1, :prerequisite => { :charisma => 10 }
  favored_class :bard
end
