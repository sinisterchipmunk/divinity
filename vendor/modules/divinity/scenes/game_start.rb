# This scene marks the start of the game for a new character. Note that it's not hard-coded: this scene is
# referenced from interfaces/something.rb

scene :game_start do
  scene_type :height_map, "data/height_maps/test.bmp"
  start_position [0,0] # unless it's overridden, f/e by a script

  # now to paint the height map, more or less.
  # multitexturing should be handled automatically.
  #
  #  texture :some_stretched_texture_id, :stretch
  #  texture :some_tiled_texture_id, :tile

  # I'm sure the rest of the details will evolve as we go.
end
