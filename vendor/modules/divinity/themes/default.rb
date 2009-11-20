theme :default do
  name "Default Theme"

  # You can also use the name of an exact class, ie
  #   set "Interface::Components::Button", . . .
  # This will affect only Button. Currently, inheritance is not supported, but will be in a future version.
  
  set :default,   :radx => 0, :rady => 0,
                  :stroke_color => "black",#"#770013",
                  :stroke_width => 1,
                  :stroke_opacity => 1,
                  :foreground_color => [ 1, 1, 1, 1 ],
                  :text_background_color => "#eeeeee"

  set :primary,   :background_image => image("data/ui/background.bmp"),
                  :scale_or_tile => :tile,
                  :fill_opacity => 0.2,
                  :fill_color => 'green',
                  :stroke_color => 'green',#"#770013",
                  :stroke_width => 0,
                  :stroke_opacity => 0.0,
                  :raised => true

  set :secondary, :fill_color => '#cccccc',
                  :radx => 8,
                  :rady => 8,
                  :foreground_color => [ 0, 0, 0, 1 ],
                  :stroke_color => 'black'

  set :text,      :radx => 0, :rady => 0,
                  :stroke_color => 'silver',
                  :raised => true,
                  :raised_size => 2,
                  :background_image => image("data/ui/background.bmp"),
                  :scale_or_tile => :tile,
                  :fill_opacity => 0.6,
                  :fill_color => "#110000"
end
