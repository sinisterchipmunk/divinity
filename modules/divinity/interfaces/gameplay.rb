interface :gameplay do
  self.background_visible = false
  unpause!

  ### image_buttons and manual layouts are less than ideal here. Scaling is the issue: People like to come out short
  # and fat. So, we probably need a VerticalImagePanel or some such similar component that is capable of maintaining
  # preferred width based on current height, or vice versa.
  panel :east do
    layout :grid, 1, 6
    image_button [0,0], actor(:player).portrait
  end
end
