interface :race_sm do
  layout :border
  label :north, "#{actor(:player).sex} #{actor(:player).race.name}".titleize
  text_area :center, actor(:player), "race.description"
end
