# Don't change this file! Configure your app in config/environment.rb and config/environments/*.rb

DIVINITY_ROOT = File.expand_path("#{File.dirname(__FILE__)}/..") unless defined?(DIVINITY_ROOT)

module Divinity
  class << self
    def boot!
      unless booted?
        preinitialize
        pick_boot.run
        require File.join(DIVINITY_ROOT, "config/environment") ### FIXME: This belongs in the various startup scripts!
      end
    end

    def booted?
      defined? Divinity::Initializer
    end

    def pick_boot
      (vendor_divinity? ? VendorBoot : GemBoot).new
    end

    def vendor_divinity?
      File.exist?(File.join(DIVINITY_ROOT, "vendor/divinity"))
    end

    def preinitialize
      load(preinitializer_path) if File.exist?(preinitializer_path)
    end

    def preinitializer_path
      File.join(DIVINITY_ROOT, "config/preinitializer.rb")
    end
  end

  class Boot
    def run
      load_initializer
      Divinity::Initializer.run(:set_load_path)
    end
  end

  class VendorBoot < Boot
    def load_initializer
      require File.join(DIVINITY_ROOT, "vendor/divinity/divinity/lib/divinity/initializer")
      Divinity::Initializer.run(:install_gem_spec_stubs)
      Divinity::GemDependency.add_frozen_gem_path
    end
  end

  class GemBoot < Boot
    def load_initializer
      self.class.load_rubygems
      load_divinity_gem
      require 'divinity/initializer'
    end

    def load_divinity_gem
      $LOAD_PATH << File.join(File.dirname(__FILE__), '../../../lib')
      if version = self.class.gem_version
        #gem 'divinity', version
      else
        #gem 'divinity'
      end
    rescue Gem::LoadError => load_error
      $stderr.puts "Missing the Divinity #{version} gem. Please `gem install -v=#{version} divinity`, update your " +
                   "DIVINITY_GEM_VERSION setting in config/environment.rb for the Divinity version you do have " +
                   "installed, or comment out RAILS_GEM_VERSION to use the latest version installed."
      exit 1
    end

    class << self
      def rubygems_version
        Gem::RubyGemsVersion rescue nil
      end

      def gem_version
        if defined? DIVINITY_GEM_VERSION
          DIVINITY_GEM_VERSION
        elsif ENV.include?("DIVINITY_GEM_VERSION")
          ENV['DIVINITY_GEM_VERSION']
        else
          parse_gem_version(read_environment_rb)
        end
      end

      def load_rubygems
        min_version = '1.3.2'
        require 'rubygems'
        unless rubygems_version >= min_version
          $stderr.puts "Divinity requires RubyGems >= #{min_version} (and you have #{rubygems_version}). Please " +
                       "`gem update --system` and try again."
          exit 1
        end
      rescue LoadError
        $stderr.puts "Divinity requires RubyGems >= #{min_version}. Please install RubyGems and try again: " +
                     "http://rubygems.rubyforge.org"
        exit 1
      end

      def parse_gem_version(text)
        $1 if text =~ /^[^#]*DIVINITY_GEM_VERSION\s*=\s*["']([!~<>=]*\s*[\d.]+)["']/
      end

      private
        def read_environment_rb
          File.read(File.join(DIVINITY_ROOT, "config/environment.rb"))
        end
    end
  end
end

Divinity.boot!
