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

ENV['DIVINITY_ROOT'] ||= File.dirname(__FILE__)

$basepath = File.join(File.dirname(__FILE__), "lib", "")
ActiveSupport::Dependencies.load_paths << File.join($basepath)

["controllers", 'models', 'views', 'helpers'].each do |i|
  ActiveSupport::Dependencies.load_paths << File.join(ENV['DIVINITY_ROOT'], "engine", i)
end

Dir.glob(File.join($basepath, "extensions", "**", "*.rb")).each do |fi|
  require fi.sub(/(.*)\.rb$/, '\1') unless fi =~ /\.svn/
end

include Geometry

[$basepath, File.join(ENV['DIVINITY_ROOT'], "engine/models")].each do |bp|
  Dir.glob(File.join(bp, "**", "*.rb")).each do |fi|
    next if File.directory? fi or fi =~ /\.svn/ or fi =~ /extensions/
    fi = fi.gsub(/^#{Regexp::escape bp}(.*)\.rb$/, '\1').camelize
    puts "loading: #{fi}" if $DEBUG
    fi.constantize
  end
end

require File.join(File.dirname(__FILE__), 'c_ext/divinity_ext')

include Magick
include Helpers::RenderHelper
