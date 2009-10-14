interface :race do
  current_race_index = 0
  panel :west do
    layout :flow
    panel do
      layout :grid, 2, 2
      partial :char_info_sm, [0,0]
      text_area actor(:player), :attribute_string, [1,0]
      #partial :race_sm, [0..1, 1]
    end
  end

  panel :center do
    layout :grid, 3, 12
    label nil, :target => actor(:player), :method => "race.name", :constraints => [1,2]
    text_area actor(:player), "race.description", :constraints => [ 1, 3..4 ]

    img = nil
    if File.exist? "data/races/#{actor(:player).sex}_#{actor(:player).race.name}.jpg"
      img = (image "data/races/#{actor(:player).sex}_#{actor(:player).race.name}.jpg", :constraints => [1, 5..7])
    end

    panel [1, 8] do
      layout :grid, 2, 1
      button :previous_class, :constraints => [0,0], :action =>
              (proc { actor(:player).race = races.values[(current_race_index -= 1) % -races.values.length] })
      button :next_class,     :constraints => [1,0], :action =>
              (proc { actor(:player).race = races.values[(current_race_index += 1) %  races.values.length] })
    end

    panel [1, 9] do
      layout :grid, 2, 1
      button :back, :constraints => [0,0], :action => :attributes
      button :continue,     :constraints => [1,0], :action => :character_class
    end  
  end
end
