interface :race_sm do
  layout :border
  label nil, :target => actor(:player), :method => "race.name", :constraints => :north
  #text_area actor(:player), "race.description", :constraints => :center
end