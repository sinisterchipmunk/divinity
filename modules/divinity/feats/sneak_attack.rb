feat :sneak_attack do
=begin
  # something like this...

  when_target_hit do |actor, target|
    if target.flat_footed?
      target.receive_damage 1.d6
    end
  end
=end
end
