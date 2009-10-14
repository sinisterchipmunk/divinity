require 'divinity_engine'
include Helpers::RenderHelper

options = YAML::load(File.read("data/config.yml")) rescue {
        :width => 800,
        :height => 600,
        :fullscreen => true
}

afps = 0.0
last_update = 0.0
frames = 0

divinity = DivinityEngine.new(options) do
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

divinity.after_shutdown do |divinity|
  File.open("data/config.yml", "w") { |f| f.print divinity.options.to_yaml }
end

divinity.go!
  