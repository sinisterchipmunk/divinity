interface :race do
  current_race_index = 0
  panel :west do
    layout :flow
    panel do
      layout :grid, 2, 2
      partial [0,0], :char_info_sm
      text_area [1,0], actor(:player), :attribute_string
    end
  end

  panel :center do
    layout :grid, 12, 12
    panel [2..9,2..9] do
      layout :border
      label :north, actor(:player), "race.name"

      img = nil
      panel :center do
        layout :grid, 2, 1
        x = 0..1

        # NOTE: If this file exists, all others are assumed to follow suit!
        file = "data/races/#{actor(:player).race.name}_#{actor(:player).sex}.jpg"
        if File.exist? file
          img = image [1,0], file
          x = 0
        end
        text_area [ x, 0 ], actor(:player), "race.description"
      end

      panel :south do
        layout :grid, 2, 1
        button [0,0], :previous_class, :action => (proc do
          actor(:player).race = races.values[(current_race_index -= 1) % -races.values.length]

          file = "data/races/#{actor(:player).race.name}_#{actor(:player).sex}.jpg"
          img.path = file if File.exist? file and img
        end)

        button [1,0], :next_class,     :action => (proc do
          actor(:player).race = races.values[(current_race_index += 1) %  races.values.length]

          file = "data/races/#{actor(:player).race.name}_#{actor(:player).sex}.jpg"
          img.path = file if File.exist? file and img
        end)
      end
    end
  end

  panel :south do
    layout :grid, 2, 1
    button [0,0], :back,     :action => :attributes
    button [1,0], :continue, :action => :character_class
  end
end
