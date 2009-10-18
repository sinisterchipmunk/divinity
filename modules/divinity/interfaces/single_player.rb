interface :single_player do
  panel :center do
    layout :grid, 3, 12
    button [1,4], :new_game,  :action => :char_info
    button [1,5], :load_game
    button [1,6], :tutorial
    button [1,7], :back,      :action => :main_menu
  end
end
