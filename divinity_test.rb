require 'divinity_engine'
include Helpers::RenderHelper

afps = 0.0
last_update = 0.0
frames = 0

divinity = DivinityEngine.new(:width => 1024, :height => 768) do
  divinity.write(:right, :bottom, "AVG FPS: #{afps.to_i}")
end

divinity.during_update do |delta|
  frames += 1000.0
  if divinity.ticks - last_update > 1000
    afps = frames / (divinity.ticks - last_update)
    last_update = divinity.ticks
    frames = 0
  end
end

divinity.during_init do
##  frame.pack
end

divinity.go!
