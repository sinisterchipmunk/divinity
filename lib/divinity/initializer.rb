require 'logger'
require 'set'
require 'pathname'

require 'divinity/configuration'
require 'divinity/ordered_options'
require 'divinity/version'
require 'divinity/plugin/locator'
require 'divinity/plugin/gem_locator'
require 'divinity/plugin/loader'
require 'divinity/content_module/loader'
require 'divinity/gem_dependency'

DIVINITY_ENV = (ENV['DIVINITY_ENV'] || 'development').dup unless defined?(DIVINITY_ENV)

require 'divinity'
require File.join(File.dirname(__FILE__), 'configuration')

module Divinity
  # The Initializer is responsible for processing the Divinity configuration, such
  # as setting the $LOAD_PATH, requiring the right frameworks, initializing
  # logging, and more. It can be run either as a single command that'll just
  # use the default configuration, like this:
  #
  #   Divinity::Initializer.run
  #
  # But normally it's more interesting to pass in a custom configuration
  # through the block running:
  #
  #   Divinity::Initializer.run do |config|
  #     config.gem 'hpricot'
  #   end
  #
  # This will use the default configuration options from Divinity::Configuration,
  # but allow for overwriting on select areas.
  class Initializer
    LOG_PATTERN = "[%5l] %d %20C - %m"

    # The Configuration instance used by this Initializer instance.
    attr_reader :configuration

    # The set of loaded plugins.
    attr_reader :loaded_plugins

    # The set of loaded content modules.
    attr_reader :loaded_content_modules

    # Whether or not all the gem dependencies have been met
    attr_reader :gems_dependencies_loaded

    # Runs the initializer. By default, this will invoke the #process method,
    # which simply executes all of the initialization routines. Alternately,
    # you can specify explicitly which initialization routine you want:
    #
    #   Divinity::Initializer.run(:set_load_path)
    #
    # This is useful if you only want the load path initialized, without
    # incurring the overhead of completely loading the entire environment.
    def self.run(command = :process, configuration = Configuration.new)
      yield configuration if block_given?
      initializer = new configuration
      initializer.send(command)
      initializer
    end

    # Create a new Initializer instance that references the given Configuration
    # instance.
    def initialize(configuration)
      @configuration = configuration
      @loaded_plugins = []
      @loaded_content_modules = []
    end

    # Sequentially step through all of the available initialization routines,
    # in order (view execution order in source).
    def process
      Divinity.configuration = configuration

      check_ruby_version
      install_gem_spec_stubs
      set_load_path
      add_gem_load_paths

      require_frameworks
      set_autoload_paths
      add_plugin_load_paths 
      load_environment
      preload_frameworks

      initialize_cache
      initialize_framework_caches

      initialize_logger
      initialize_framework_logging

      initialize_dependency_mechanism
      initialize_whiny_nils

      initialize_i18n

      require 'divinity_engine'
      initialize_framework_settings
      initialize_framework_views

      add_support_load_paths

      check_for_unbuilt_gems

      load_gems
      load_plugins
      load_content_modules

      # pick up any gems that plugins depend on
      add_gem_load_paths
      load_gems
      check_gem_dependencies

      # bail out if gems are missing - note that check_gem_dependencies will have
      # already called abort() unless $gems_rake_task is set
      return unless gems_dependencies_loaded

      load_application_initializers

      # the framework is now fully initialized
      after_initialize

      # Observers are loaded after plugins in case Observers or observed models are modified by plugins.
      load_observers

      # Load view path cache
      load_view_paths

      # Load application classes
      load_application_classes

      # Disable dependency loading during request cycle
      disable_dependency_loading

      # Flag initialized
      Divinity.initialized = true
    end

    # Check for valid Ruby version
    # This is done in an external file, so we can use it
    # from the `divinity` program as well without duplication.
    def check_ruby_version
      require 'ruby_version_check'
    end

    # If Divinity is vendored and RubyGems is available, install stub GemSpecs
    # for Divinity and its dependencies. This allows Gem plugins to depend on Divinity even when
    # the Gem version of Divinity shouldn't be loaded.
    def install_gem_spec_stubs
      unless Divinity.respond_to?(:vendor_divinity?)
        abort %{Your config/boot.rb is outdated: Run "rake divinity:update".}
      end

      if Divinity.vendor_divinity?
        begin; require "rubygems"; rescue LoadError; return; end

        stubs = divinity_frameworks
        stubs << "divinity"
        stubs.reject! { |s| Gem.loaded_specs.key?(s) }

        stubs.each do |stub|
          Gem.loaded_specs[stub] = Gem::Specification.new do |s|
            s.name = stub
            s.version = Divinity::VERSION::STRING
            s.loaded_from = ""
          end
        end
      end
    end

    # Set the <tt>$LOAD_PATH</tt> based on the value of
    # Configuration#load_paths. Duplicates are removed.
    def set_load_path
      load_paths = configuration.load_paths + configuration.framework_paths
      load_paths.reverse_each { |dir| $LOAD_PATH.unshift(dir) if File.directory?(dir) }
      $LOAD_PATH.uniq!
    end

    # Set the paths from which Divinity will automatically load source files, and
    # the load_once paths.
    def set_autoload_paths
      ActiveSupport::Dependencies.load_paths = configuration.load_paths.uniq
      ActiveSupport::Dependencies.load_once_paths = configuration.load_once_paths.uniq

      extra = ActiveSupport::Dependencies.load_once_paths - ActiveSupport::Dependencies.load_paths
      unless extra.empty?
        abort <<-end_error
          load_once_paths must be a subset of the load_paths.
          Extra items in load_once_paths: #{extra * ','}
        end_error
      end

      # Freeze the arrays so future modifications will fail rather than do nothing mysteriously
      configuration.load_once_paths.freeze
    end

    # Requires all frameworks specified by the Configuration#frameworks
    # list.
    def require_frameworks
      configuration.frameworks.each { |framework| require(framework.to_s) }
    rescue LoadError => e
      # Re-raise as RuntimeError because Mongrel would swallow LoadError.
      raise e.to_s
    end

    # Preload all frameworks specified by the Configuration#frameworks.
    # Used by Passenger to ensure everything's loaded before forking and
    # to avoid autoload race conditions in JRuby.
    def preload_frameworks
      if configuration.preload_frameworks
        configuration.frameworks.each do |framework|
          # String#classify and #constantize aren't available yet.
          toplevel = Object.const_get(framework.to_s.gsub(/(?:^|_)(.)/) { $1.upcase })
          toplevel.load_all! if toplevel.respond_to?(:load_all!)
        end
      end
    end

    # Add the load paths used by support functions such as the info controller
    def add_support_load_paths
    end

    # Adds all load paths from plugins to the global set of load paths, so that
    # code from plugins can be required (explicitly or automatically via ActiveSupport::Dependencies).
    def add_plugin_load_paths
      plugin_loader.add_plugin_load_paths
    end

    def add_gem_load_paths
      Divinity::GemDependency.add_frozen_gem_path
      unless @configuration.gems.empty?
        require "rubygems"
        @configuration.gems.each { |gem| gem.add_load_paths }
      end
    end

    def load_gems
      unless $gems_rake_task
        @configuration.gems.each { |gem| gem.load }
      end
    end

    def check_for_unbuilt_gems
      unbuilt_gems = @configuration.gems.select(&:frozen?).reject(&:built?)
      if unbuilt_gems.size > 0
        # don't print if the gems:build rake tasks are being run
        unless $gems_build_rake_task
          abort <<-end_error
The following gems have native components that need to be built
  #{unbuilt_gems.map { |gem| "#{gem.name}  #{gem.requirement}" } * "\n  "}

You're running:
  ruby #{Gem.ruby_version} at #{Gem.ruby}
  rubygems #{Gem::RubyGemsVersion} at #{Gem.path * ', '}

Run `rake gems:build` to build the unbuilt gems.
          end_error
        end
      end
    end

    def check_gem_dependencies
      unloaded_gems = @configuration.gems.reject { |g| g.loaded? }
      if unloaded_gems.size > 0
        @gems_dependencies_loaded = false
        # don't print if the gems rake tasks are being run
        unless $gems_rake_task
          abort <<-end_error
Missing these required gems:
  #{unloaded_gems.map { |gem| "#{gem.name}  #{gem.requirement}" } * "\n  "}

You're running:
  ruby #{Gem.ruby_version} at #{Gem.ruby}
  rubygems #{Gem::RubyGemsVersion} at #{Gem.path * ', '}

Run `rake gems:install` to install the missing gems.
          end_error
        end
      else
        @gems_dependencies_loaded = true
      end
    end

    # Loads all plugins in <tt>config.plugin_paths</tt>.  <tt>plugin_paths</tt>
    # defaults to <tt>vendor/plugins</tt> but may also be set to a list of
    # paths, such as
    #   config.plugin_paths = ["#{DIVINITY_ROOT}/lib/plugins", "#{DIVINITY_ROOT}/vendor/plugins"]
    #
    # In the default implementation, as each plugin discovered in <tt>plugin_paths</tt> is initialized:
    # * its +lib+ directory, if present, is added to the load path (immediately after the applications lib directory)
    # * <tt>init.rb</tt> is evaluated, if present
    #
    # After all plugins are loaded, duplicates are removed from the load path.
    # If an array of plugin names is specified in config.plugins, only those plugins will be loaded
    # and they plugins will be loaded in that order. Otherwise, plugins are loaded in alphabetical
    # order.
    #
    # if config.plugins ends contains :all then the named plugins will be loaded in the given order and all other
    # plugins will be loaded in alphabetical order
    def load_plugins
      plugin_loader.load_plugins
    end

    # Loads all content modules in <tt>config.content_module_paths</tt>, which defaults to <tt>vendor/mods</tt> but
    # may also be set to a list of paths, such as
    #   config.content_module_paths = ["#{DIVINITY_ROOT}/lib/mods", "#{DIVINITY_ROOT}/vendor/mods"]
    #
    # If the file config/content_modules.yml is found, then the modules will be loaded in the order specified there.
    # Otherwise, all content modules will be loaded alphabetically.
    def load_content_modules
      content_module_loader.load_modules
    end

    def content_module_loader
      @module_loader ||= configuration.content_module_loader.new(self)
    end

    def plugin_loader
      @plugin_loader ||= configuration.plugin_loader.new(self)
    end

    # Loads the environment specified by Configuration#environment_path, which
    # is typically one of development, test, or production.
    def load_environment
      silence_warnings do
        return if @environment_loaded
        @environment_loaded = true

        config = configuration
        constants = self.class.constants

        eval(IO.read(configuration.environment_path), binding, configuration.environment_path)

        (self.class.constants - constants).each do |const|
          Object.const_set(const, self.class.const_get(const))
        end
      end
    end

    def load_observers
      # TODO: Implement observers
    end

    def load_view_paths
      Engine::Controller::ViewPaths.load!
    end

    # Eager load application classes
    def load_application_classes
      return if $divinity_rake_task
      if configuration.cache_classes
        configuration.eager_load_paths.each do |load_path|
          matcher = /\A#{Regexp.escape(load_path)}(.*)\.rb\Z/
          Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
            require_dependency file.sub(matcher, '\1')
          end
        end
      end
    end

    def initialize_cache
      unless defined?(DIVINITY_CACHE)
        silence_warnings { Object.const_set "DIVINITY_CACHE", ActiveSupport::Cache.lookup_store(configuration.cache_store) }
      end
    end

    def initialize_framework_caches
      Divinity.cache ||= DIVINITY_CACHE
    end

    # If the DIVINITY_DEFAULT_LOGGER constant is already set, this initialization
    # routine does nothing. If the constant is not set, and Configuration#logger
    # is not +nil+, this also does nothing. Otherwise, a new logger instance
    # is created at Configuration#log_path, with a default log level of
    # Configuration#log_level.
    #
    # If the log could not be created, the log will be set to output to
    # +STDERR+, with a log level of +WARN+.
    def initialize_logger
      # if the environment has explicitly defined a logger, use it
      return if Divinity.logger

      unless logger = configuration.logger
        formatter = Log4r::PatternFormatter.new(:pattern => LOG_PATTERN)
        Log4r::StderrOutputter.new('console', :formatter => formatter)
        begin
          Log4r::Logger.root.level = Log4r.const_get(configuration.log_level.to_s.upcase)
          Log4r::FileOutputter.new('logfile', :formatter => formatter, :filename => configuration.log_path)
          logger = Log4r::Logger.new('Divinity')
          logger.add('logfile')
          logger.add('console') unless configuration.environment == 'production'
          logger = Log4r::Logger.new("Divinity::#{configuration.logger_name}")
        rescue StandardError => e
          Log4r::Logger.root.level = Log4r::WARN
          Log4r::Logger.new('Divinity').add('console')
          logger = Log4r::Logger.new("Divinity::#{configuration.logger_name}")
          logger.warn $!.message
          logger.warn(
            "Divinity Error: Unable to access log file. Please ensure that #{configuration.log_path} exists and is chmod 0666. " +
            "The log level has been raised to WARN and the output directed to STDERR until the problem is fixed."
          )
        end
      end

      silence_warnings do
        Object.const_set "DIVINITY_DEFAULT_LOGGER", logger
        Object.const_set "DIVINITY_SYSTEM_LOGGER",  Log4r::Logger.new("Divinity::System")
        Object.const_set "DIVINITY_ENGINE_LOGGER",  Log4r::Logger.new("Divinity::Engine")
      end
    end

    # Sets the logger.
    def initialize_framework_logging
      ActiveSupport::Dependencies.logger ||= Divinity.system_logger
      # This works fine for Rails, but in Divinity there's just too many calls to the cache. It hangs the engine and
      # floods the logs.
      #Divinity.cache.logger ||= Divinity.system_logger
    end

    # Sets +Engine::Controller::ViewPaths#default_view_paths+ to Configuration#view_path.
    def initialize_framework_views
      Engine::Controller::ViewPaths.default_view_paths << configuration.view_path
    end

    # Sets the dependency loading mechanism based on the value of
    # Configuration#cache_classes.
    def initialize_dependency_mechanism
      ActiveSupport::Dependencies.mechanism = configuration.cache_classes ? :require : :load
    end

    # Loads support for "whiny nil" (noisy warnings when methods are invoked
    # on +nil+ values) if Configuration#whiny_nils is true.
    def initialize_whiny_nils
      require('active_support/whiny_nil') if configuration.whiny_nils
    end

    # Set the i18n configuration from config.i18n but special-case for the load_path which should be
    # appended to what's already set instead of overwritten.
    def initialize_i18n
      configuration.i18n.each do |setting, value|
        if setting == :load_path
          I18n.load_path += value
        else
          I18n.send("#{setting}=", value)
        end
      end
    end

    # Initializes framework-specific settings for each of the loaded frameworks
    # (Configuration#frameworks). The available settings map to the accessors
    # on each of the corresponding Base classes.
    def initialize_framework_settings
      configuration.active_support.each do |setting, value|
        ActiveSupport.send("#{setting}=", value)
      end
    end

    # Fires the user-supplied after_initialize block (Configuration#after_initialize)
    def after_initialize
      if gems_dependencies_loaded
        configuration.after_initialize_blocks.each do |block|
          block.call
        end
      end
    end

    def load_application_initializers
      if gems_dependencies_loaded
        Dir["#{configuration.root_path}/config/initializers/**/*.rb"].sort.each do |initializer|
          load(initializer)
        end
      end
    end

    def disable_dependency_loading
      if configuration.cache_classes && !configuration.dependency_loading
        ActiveSupport::Dependencies.unhook!
      end
    end
  end
end
