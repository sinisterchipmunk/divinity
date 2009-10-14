interface :single_player do
  panel :center do
    layout :grid, 3, 12
    button :new_game,  :constraints => [1, 4], :action => :char_info
    button :load_game, :constraints => [1, 5]
    button :tutorial,  :constraints => [1, 6]
    button :back,      :constraints => [1, 7], :action => :main_menu
  end
end
