require File.join('divinity.so')

# gem dependencies and core files
if RUBY_VERSION >= '1.9'
  require 'fileutils'
else
  require 'ftools'
end
require 'matrix'
require 'mathn'

# core extensions
require 'extensions/magick_extensions'
Dir.glob(File.join(File.dirname(__FILE__), "extensions", "**", "*.rb")).each do |fi|
  require fi.sub(/(.*)\.rb$/, '\1') unless fi =~ /\.svn/
end

# engine libraries
#puts $LOAD_PATH
#$LOAD_PATH << File.dirname(__FILE__)
ActiveSupport::Dependencies.load_paths << File.dirname(__FILE__)
ActiveSupport::Dependencies.load_once_paths << File.dirname(__FILE__)
Dir[File.join(File.dirname(__FILE__), "dependencies", "**", "*.rb")].each do |fi|
  require fi if File.file?(fi)
end
