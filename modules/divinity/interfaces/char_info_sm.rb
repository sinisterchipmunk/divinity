interface :char_info_sm do
  scroll_panel :center do
    layout :border
    label nil, :constraints => :north, :target => actor(:player), :method => :name
    image actor(:player).portrait, :constraints => :center
  end
end
