ENV["DIVINITY_ENV"] = "test"
ENV["DRY_RUN"] = 'true'
DIVINITY_ROOT = "."

# Fake an application environment that we'll run the engine tests under
require 'rubygems'
$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')
require "divinity/initializer"

module Divinity
  class << self
    def vendor_divinity?
      false
    end
  end
end

Divinity::Initializer.run(:set_load_path)
Divinity::Initializer.run
require 'divinity_test_help'
