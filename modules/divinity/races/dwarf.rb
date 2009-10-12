race :dwarf do
  constitution 2
  charisma -2
  size :medium
  speed 20
  ability :darkvision
  skill :search, 2
  saving_throw 2, :poison
  saving_throw 2, :spell
  attack_bonus 1, :vs => [:orcs, :goblins]
  armor_class_bonus 4, :vs => :giants
  skill :appraise, 2
  skill :craft, 2
  language :common, :dwarven
  bonus_languages :giant, :gnome, :goblin, :orc, :terran, :undercommon
  favored_class :fighter
end
