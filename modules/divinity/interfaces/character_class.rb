interface :character_class do
  panel :west do
    layout :flow
    panel do
      layout :grid, 2, 2
      partial :char_info_sm, [0,0]
      text_area actor(:player), :attribute_string, [1,0]
      partial :race_sm, [0..1, 1]
    end
  end
end