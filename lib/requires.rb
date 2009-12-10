require File.join('divinity.so')

# gem dependencies and core files
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
require 'log4r'
require File.join(File.dirname(__FILE__), "divinity")

# core extensions
require 'extensions/magick_extensions'
Dir.glob(File.join(File.dirname(__FILE__), "extensions", "**", "*.rb")).each do |fi|
  require fi.sub(/(.*)\.rb$/, '\1') unless fi =~ /\.svn/
end

# engine libraries
ActiveSupport::Dependencies.load_paths << File.dirname(__FILE__)
ActiveSupport::Dependencies.load_once_paths << File.dirname(__FILE__)
Dir[File.join(File.dirname(__FILE__), "dependencies", "**", "*.rb")].each do |fi|
  require fi if File.file?(fi)
end


=begin
Dir[File.join(File.dirname(__FILE__), "*")].each do |fi|
  if File.directory?(fi)
    library_name = File.basename(fi)
    Object.const_set(library_name.camelize, Module.new) unless (Object.const_get(library_name.camelize) rescue nil)
  end
end
require 'math/dice'
require 'math/die'
require 'geometry/dimension'
require 'geometry/plane'
require 'geometry/point'
require 'geometry/rectangle'
require 'geometry/vertex3d'
require 'geometry/vector3d'
require 'helpers/render_helper'
=end
