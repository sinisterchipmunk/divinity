interface :race_sm do
  layout :border
  label "#{actor(:player).race.name} #{actor(:player).sex}".titleize, :constraints => :north
  #:target => actor(:player), :method => "race.name", :constraints => :north
  #text_area actor(:player), "race.description", :constraints => :center
end