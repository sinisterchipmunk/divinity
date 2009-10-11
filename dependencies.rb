require 'rubygems'
require 'opengl'
require 'ftools'
require 'sdl'
require 'activesupport'
require 'gl'
require 'glu'
require 'RMagick'

ActiveSupport::Dependencies.load_paths << File.join(File.dirname(__FILE__), "lib")

Dir.glob(File.join(File.dirname(__FILE__), "extensions", "**", "*.rb")).each do |fi|
  require fi.sub(/(.*)\.rb$/, '\1') unless fi =~ /\.svn/
end
