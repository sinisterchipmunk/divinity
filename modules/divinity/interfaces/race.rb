interface :race do
  current_race_index = 0

  panel :center do
    layout :grid, 3, 12
    label nil, :target => actor(:player), :method => "race.name", :constraints => [1,3]
    text_area actor(:player), "race.description", :constraints => [ 1, 4..5 ]

    panel [1, 9] do
      layout :grid, 2, 1
      button :previous_class, :constraints => [0,0], :action =>
              (proc { actor(:player).race = races.values[(current_race_index -= 1) % -races.values.length] })
      button :next_class,     :constraints => [1,0], :action =>
              (proc { actor(:player).race = races.values[(current_race_index += 1) %  races.values.length] })
    end

    panel [1, 10] do
      layout :grid, 2, 1
      button :back, :constraints => [0,0], :action => :attributes
      button :continue,     :constraints => [1,0], :action => :character_class
    end  
  end
end
