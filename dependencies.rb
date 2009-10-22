require 'rubygems'
require 'opengl'
require 'ftools'
require 'sdl'
require 'activesupport'
require 'gl'
require 'glu'
require 'RMagick'
require 'matrix'
require 'mathn'

$basepath = File.join(File.dirname(__FILE__), "lib", "")
ActiveSupport::Dependencies.load_paths << File.join($basepath)

Dir.glob(File.join($basepath, "extensions", "**", "*.rb")).each do |fi|
  require fi.sub(/(.*)\.rb$/, '\1') unless fi =~ /\.svn/
end

include Geometry

Dir.glob(File.join($basepath, "**", "*.rb")).each do |fi|
  next if File.directory? fi or fi =~ /\.svn/ or fi =~ /extensions/
  fi = fi.gsub(/^#{Regexp::escape $basepath}(.*)\.rb$/, '\1').camelize
  puts "loading: #{fi}" if $DEBUG
  fi.constantize
end

include Magick
