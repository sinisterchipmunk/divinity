unless defined? DIVINITY_ROOT
  DIVINITY_ROOT = File.expand_path(ENV['DIVINITY_ROOT'] || Dir.pwd)
end

unless defined? DIVINITY_FRAMEWORK_ROOT
  DIVINITY_FRAMEWORK_ROOT = File.expand_path(ENV['DIVINITY_FRAMEWORK_ROOT'] || File.join(File.dirname(__FILE__), ".."))
end

require 'requires'

#["controllers", 'models', 'views', 'helpers'].each do |i|
#  path = File.join(DIVINITY_FRAMEWORK_ROOT, "builtin", i)
#  ActiveSupport::Dependencies.load_paths << path
#  ActiveSupport::Dependencies.load_once_paths << path
#end

include Magick
include Geometry
include Helpers::RenderHelper
