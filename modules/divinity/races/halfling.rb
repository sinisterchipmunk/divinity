race :halfling do
  dexterity 2
  strength -2
  size :small
  speed 20
  skill :climb, 2
  skill :jump, 2
  skill :listen, 2
  skill :move_silently, 2
  saving_throw 1
  saving_throw 2, :fear
  attack_bonus 1, :with => [:thrown, :sling]
  language :common, :halfling
  bonus_languages :dwarven, :elven, :gnome, :goblin, :orc
  favored_class :rogue
end
