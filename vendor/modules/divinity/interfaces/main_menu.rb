interface :main_menu do
  panel :center do
    layout :grid, 3, 12
    button [1,4], :single_player
    #button [1,5], :multi_player
    button [1,6], :options
    button [1,7], :quit
  end
end
