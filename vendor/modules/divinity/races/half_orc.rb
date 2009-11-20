race :half_orc do
  name "Half-orc"
  strength 2
  intelligence -2
  charisma -2
  minimum :intelligence => 3
  size :medium
  speed 30
  ability :darkvision
  language :common, :orc
  bonus_languages :draconic, :giant, :gnoll, :goblin, :abyssal
  favored_class :barbarian 
end