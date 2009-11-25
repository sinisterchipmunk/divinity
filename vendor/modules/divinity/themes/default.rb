theme :default do
  name "Default Theme"

  # You can also use the name of a controller, ie
  #   set "components/button", . . .
  # This will affect only Components::ButtonController.

  set :default do
    # Note on background colors: these take priority over background images! So specify an alpha channel
    # if you want them to be opaque, or specify "transparent" if you don't want a background color at all.
    background :color => "transparent"
    border :round_rect, :radx => 10, :rady => 10
    stroke :color => "#ccc", :width => 2, :opacity => 0
    font :color => "#000",
         :family => "Arial",
         :style => "normal",# italic, oblique, any
         :weight => 400,
         :pointsize => 12,
         :antialias => true,
         :stretch => "normal" # ultraCondensed, extraCondensed, condensed, semiCondensed, semiExpanded,
                              # expanded, extraExpanded, ultraExpanded, any
  end

  # All remaining sets inherit their attributes from the :default set. So we don't need to specify any value
  # that we don't plan on overriding. You can directly inherit attributes from other sets with the
  # #inherit method.

  set :primary do
    background :image => "data/ui/background.bmp", :mode => :tile, :color => "#0a02"
  end

  # looks like an object set into its parent, or 'inset', like a button that is pressed.
  set :inset do
    inherit :primary
    background :effects => Effect(:button, :inset)
  end

  # looks like an object set out of parent, or 'outset', like a button that is not pressed.
  set :outset do
    inherit :primary
    #background :effects => Effect(:button, :outset)
    effect Effect(:button, :outset)
  end

  set :secondary do
    fill :color => "#cccccc"
    border :radx => 8, :rady => 8
    stroke :color => "black"
  end
end
