theme :default do
  name "Default Theme"

  set :default do
    # Note on background colors: these take priority over background images! So specify an alpha channel
    # if you want them to be opaque, or specify "transparent" if you don't want a background color at all.
    background :color => "transparent"
    border :round_rect, :radx => 10, :rady => 10
    stroke :color => "#ccc", :width => 2, :opacity => 0
    font :color => "#000",
         :family => "Arial",
         :style => "normal",
         :weight => 400,
         :pointsize => 12,
         :antialias => true,
         :stretch => "normal"
  end

  set :primary do
    background :image => "data/ui/background.bmp", :mode => :tile, :color => "#0a02"
  end

  # looks like an object set into its parent, or 'inset', like a button that is pressed.
  set :inset do
    inherit :primary
    effect Effect(:button, :inset)
  end

  # looks like an object set out of parent, or 'outset', like a button that is not pressed.
  set :outset do
    inherit :primary
    effect Effect(:button, :outset)
  end
end
