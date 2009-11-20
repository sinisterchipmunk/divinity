race :half_elf do
  name "Half-elf"
  size :medium
  speed 30
  immunity :sleep
  saving_throw 2, :enchantment
  ability :low_light_vision
  skill :listen, 1
  skill :search, 1
  skill :spot, 1
  skill :diplomacy, 2
  skill :gather_information, 2
  language :common, :elven
  bonus_languages :any
  favored_class :any
end
