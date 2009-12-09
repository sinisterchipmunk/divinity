## need some TLC here
$LOAD_PATH << "ext/divinity"

require 'rubygems'
if RUBY_VERSION >= '1.9'
  require 'fileutils'
else
  require 'ftools'
end
require 'opengl'
require 'sdl'
require 'activesupport'
require 'gl'
require 'glu'
require 'RMagick'
require 'matrix'
require 'mathn'
require 'lib/extensions/magick_extensions'

ENV['DIVINITY_ROOT'] ||= File.join(File.dirname(__FILE__), "..")

$basepath = File.join(ENV['DIVINITY_ROOT'], "lib", "")
paths = [ $basepath ]

["controllers", 'models', 'views', 'helpers'].each do |i|
  paths << File.join(ENV['DIVINITY_ROOT'], "engine", i)
end
ActiveSupport::Dependencies.load_paths.concat paths
ActiveSupport::Dependencies.load_once_paths.concat paths
paths = nil

Dir.glob(File.join($basepath, "extensions", "**", "*.rb")).each do |fi|
  require fi.sub(/(.*)\.rb$/, '\1') unless fi =~ /\.svn/
end

[$basepath, File.join(ENV['DIVINITY_ROOT'], "engine/models")].each do |bp|
  Dir.glob(File.join(bp, "**", "*.rb")).each do |fi|
    next if File.directory? fi or fi =~ /\.svn/ or fi =~ /extensions/
    fi = fi.gsub(/^#{Regexp::escape bp}(.*)\.rb$/, '\1').camelize
    puts "loading: #{fi}" if $DEBUG
    fi.constantize unless fi == "Dependencies" || fi == "DivinityEngine" || fi == "Divinity"
  end
end

require File.join('divinity.so')

include Magick
include Geometry
include Helpers::RenderHelper
