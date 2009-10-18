interface :char_info_sm do
  panel :center do
    layout :border
    label :north,  actor(:player), :name
    image :center, actor(:player).portrait
  end
end
