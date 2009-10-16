interface :race_sm do
  layout :border
  label "#{actor(:player).sex} #{actor(:player).race.name}".titleize, :constraints => :north
  text_area actor(:player), "race.description", :constraints => :center
end