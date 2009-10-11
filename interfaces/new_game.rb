for_interface :new_game do
  panel :center do
    layout :grid, 3, 12  # 3 wide, 12 high
    panel [1, 1] do
      layout :grid, 2, 1 # 2 wide, 1 high
      label "Character Name:", :constraints => [0, 0]
      text_field :pc_character_name, :constraints => [1, 0]
    end
    button :back,      :constraints => [1, 7], :action => :single_player
  end
end
