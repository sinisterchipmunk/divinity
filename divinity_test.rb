require 'divinity_engine'
include Helpers::RenderHelper

options = YAML::load(File.read("data/config.yml")) rescue {
        :width => 800,
        :height => 600,
        :fullscreen => true
}

afps = 0.0
frames = 0
ch = 0.0
t = 0
last_tick = 0
scene = World::Scenes::HeightMap.new("data/height_maps/test.bmp")

divinity = DivinityEngine.new(options) do
  glColor4f 1, 1, 1, 1
  scene.render
end

divinity.after_render do
  glColor4f 1, 1, 1, 1
  divinity.write(:right, :bottom, "AVG FPS: #{afps.to_i}")
  # this logic usually goes in the during_update block, but during_update only fires if the game is unpaused --
  # since the game is paused at the menu screens, it would never fire on them.
  # convert delta to seconds (it's in milliseconds atm)
  delta = ((divinity.ticks - last_tick) / 1000.0)
  last_tick = divinity.ticks
  if delta > 0 # to prevent divide-by-zero
    frames += 1.0 / delta # one frame per delta = 1/delta
    ch += 1               # one pass
    t += delta            # total change in time over ch passes
    if t >= 0.5           # update avg framerate every half-second
      afps = frames / ch  # average of frames-per-delta over the last ch passes
      ch, t, frames = 0, 0, 0
    end
  end
end

# IMPORTANT: When multithreading is implemented, #during_update will NO LONGER be a reliable
# way to count frames! This logic will need to be moved to #during_render to verify that it is
# running on the same thread as the frames themselves are.
divinity.during_update do |delta|
  scene.update delta
end

divinity.after_shutdown do |divinity|
  File.open("data/config.yml", "w") { |f| f.print divinity.options.to_yaml }
end

divinity.go!
  