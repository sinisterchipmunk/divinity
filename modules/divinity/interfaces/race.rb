interface :race do
  current_race_index = 0

  panel :center do
    layout :grid, 3, 12
    label nil, :target => actor(:player), :method => "race.name", :constraints => [1,3]

    panel [1, 9] do
      layout :grid, 2, 1
      button :previous, :constraints => [0,0], :action =>
              (proc { actor(:player).race = races.values[(current_race_index -= 1) % -races.values.length] })
      button :next,     :constraints => [1,0], :action =>
              (proc { actor(:player).race = races.values[(current_race_index += 1) %  races.values.length] })
    end
  end
end
