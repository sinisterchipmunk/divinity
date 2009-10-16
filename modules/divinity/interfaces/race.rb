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
    layout :grid, 12, 12
    panel [2..9,2..9] do
      layout :border
      label nil, :target => actor(:player), :method => "race.name", :constraints => :north

      img = nil
      panel :center do
        layout :grid, 2, 1
        x = 0..1

        # NOTE: If this file exists, all others are assumed to follow suit!
        file = "data/races/#{actor(:player).race.name}_#{actor(:player).sex}.jpg"
        if File.exist? file
          img = image file, :constraints => [1, 0]
          x = 0
        end
        text_area actor(:player), "race.description", :constraints => [ x, 0 ]
      end

      panel :south do
        layout :grid, 2, 1
        button :previous_class, :constraints => [0,0], :action => (proc do
          actor(:player).race = races.values[(current_race_index -= 1) % -races.values.length]

          file = "data/races/#{actor(:player).race.name}_#{actor(:player).sex}.jpg"
          img.path = file if File.exist? file and img
        end)

        button :next_class,     :constraints => [1,0], :action => (proc do
          actor(:player).race = races.values[(current_race_index += 1) %  races.values.length]

          file = "data/races/#{actor(:player).race.name}_#{actor(:player).sex}.jpg"
          img.path = file if File.exist? file and img
        end)
      end
    end
  end

  panel :south do
    layout :grid, 2, 1
    button :back, :constraints => [0,0], :action => :attributes
    button :continue,     :constraints => [1,0], :action => :character_class
  end
end
