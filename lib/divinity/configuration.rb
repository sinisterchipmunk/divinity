module Divinity
  # The Configuration class holds all the parameters for the Initializer and
  # ships with defaults that suits most Divinity applications. But it's possible
  # to overwrite everything. Usually, you'll create a Configuration file
  # implicitly through the block running on the Initializer, but it's also
  # possible to create the Configuration instance in advance and pass it in
  # like this:
  #
  #   config = Divinity::Configuration.new
  #   Divinity::Initializer.run(:process, config)
  class Configuration
    # The application's base directory.
    attr_reader :root_path

    # The name of the log entries. By default it's equal to the working directory, camelized.
    attr_accessor :logger_name

    # A stub for setting options on ActiveSupport.
    attr_accessor :active_support

    # Whether to preload all frameworks at startup.
    attr_accessor :preload_frameworks

    # Whether or not classes should be cached (set to false if you want
    # application classes to be reloaded on each request)
    attr_accessor :cache_classes

    # The list of paths that should be searched for controllers. (Defaults
    # to <tt>app/controllers</tt>.)
    attr_accessor :controller_paths

    # The path to the database configuration file to use. (Defaults to
    # <tt>config/database.yml</tt>.)
    attr_accessor :database_configuration_file

    # The path to the routes configuration file to use. (Defaults to
    # <tt>config/routes.rb</tt>.)
    attr_accessor :routes_configuration_file

    # The list of divinity framework components that should be loaded. (Defaults
    # to <tt>:active_record</tt>, <tt>:action_controller</tt>,
    # <tt>:action_view</tt>, <tt>:action_mailer</tt>, and
    # <tt>:active_resource</tt>).
    attr_accessor :frameworks

    # An array of additional paths to prepend to the load path. By default,
    # all +app+, +lib+, +vendor+ and mock paths are included in this list.
    attr_accessor :load_paths

    # An array of paths from which Divinity will automatically load from only once.
    # All elements of this array must also be in +load_paths+.
    attr_accessor :load_once_paths

    # An array of paths from which Divinity will eager load on boot if cache
    # classes is enabled. All elements of this array must also be in
    # +load_paths+.
    attr_accessor :eager_load_paths

    # The log level to use for the default Divinity logger. In production mode,
    # this defaults to <tt>:info</tt>. In development mode, it defaults to
    # <tt>:debug</tt>.
    attr_accessor :log_level

    # The path to the log file to use. Defaults to log/#{environment}.log
    # (e.g. log/development.log or log/production.log).
    attr_accessor :log_path

    # The specific logger to use. By default, a logger will be created and
    # initialized using #log_path and #log_level, but a programmer may
    # specifically set the logger to use via this accessor and it will be
    # used directly.
    attr_accessor :logger

    # The specific cache store to use. By default, the ActiveSupport::Cache::Store will be used.
    attr_accessor :cache_store

    # The root of the application's views. (Defaults to <tt>app/views</tt>.)
    attr_accessor :view_path

    # Set to +true+ if you want to be warned (noisily) when you try to invoke
    # any method of +nil+. Set to +false+ for the standard Ruby behavior.
    attr_accessor :whiny_nils

    # The list of plugins to load. If this is set to <tt>nil</tt>, all plugins will
    # be loaded. If this is set to <tt>[]</tt>, no plugins will be loaded. Otherwise,
    # plugins will be loaded in the order specified.
    attr_reader :plugins
    def plugins=(plugins)
      @plugins = plugins.nil? ? nil : plugins.map { |p| p.to_sym }
    end

    # The path to the root of the plugins directory. By default, it is in
    # <tt>vendor/plugins</tt>.
    attr_accessor :plugin_paths

    # The classes that handle finding the desired plugins that you'd like to load for
    # your application. By default it is the Divinity::Plugin::FileSystemLocator which finds
    # plugins to load in <tt>vendor/plugins</tt>. You can hook into gem location by subclassing
    # Divinity::Plugin::Locator and adding it onto the list of <tt>plugin_locators</tt>.
    attr_accessor :plugin_locators

    # The class that handles loading each plugin. Defaults to Divinity::Plugin::Loader, but
    # a sub class would have access to fine grained modification of the loading behavior. See
    # the implementation of Divinity::Plugin::Loader for more details.
    attr_accessor :plugin_loader

    # Enables or disables plugin reloading.  You can get around this setting per plugin.
    # If <tt>reload_plugins?</tt> is false, add this to your plugin's <tt>init.rb</tt>
    # to make it reloadable:
    #
    #   ActiveSupport::Dependencies.load_once_paths.delete lib_path
    #
    # If <tt>reload_plugins?</tt> is true, add this to your plugin's <tt>init.rb</tt>
    # to only load it once:
    #
    #   ActiveSupport::Dependencies.load_once_paths << lib_path
    #
    attr_accessor :reload_plugins

    # Returns true if plugin reloading is enabled.
    def reload_plugins?
      !!@reload_plugins
    end

    # Enables or disables dependency loading during the request cycle. Setting
    # <tt>dependency_loading</tt> to true will allow new classes to be loaded
    # during a request. Setting it to false will disable this behavior.
    #
    # Those who want to run in a threaded environment should disable this
    # option and eager load or require all there classes on initialization.
    #
    # If <tt>cache_classes</tt> is disabled, dependency loaded will always be
    # on.
    attr_accessor :dependency_loading

    # An array of gems that this divinity application depends on.  Divinity will automatically load
    # these gems during installation, and allow you to install any missing gems with:
    #
    #   rake gems:install
    #
    # You can add gems with the #gem method.
    attr_accessor :gems

    # Adds a single Gem dependency to the divinity application. By default, it will require
    # the library with the same name as the gem. Use :lib to specify a different name.
    #
    #   # gem 'aws-s3', '>= 0.4.0'
    #   # require 'aws/s3'
    #   config.gem 'aws-s3', :lib => 'aws/s3', :version => '>= 0.4.0', \
    #     :source => "http://code.whytheluckystiff.net"
    #
    # To require a library be installed, but not attempt to load it, pass :lib => false
    #
    #   config.gem 'qrp', :version => '0.4.1', :lib => false
    def gem(name, options = {})
      @gems << Divinity::GemDependency.new(name, options)
    end

    # Deprecated options:
    def breakpoint_server(_ = nil)
      $stderr.puts %(
      *******************************************************************
      * config.breakpoint_server has been deprecated and has no effect. *
      *******************************************************************
      )
    end
    alias_method :breakpoint_server=, :breakpoint_server

    # Sets the default +time_zone+.  Setting this will enable +time_zone+
    # awareness for Active Record models and set the Active Record default
    # timezone to <tt>:utc</tt>.
    attr_accessor :time_zone

    # Accessor for i18n settings.
    attr_accessor :i18n

    # Create a new Configuration instance, initialized with the default
    # values.
    def initialize
      set_root_path!

      self.frameworks                   = default_frameworks
      self.load_paths                   = default_load_paths
      self.load_once_paths              = default_load_once_paths
      self.eager_load_paths             = default_eager_load_paths
      self.log_path                     = default_log_path
      self.log_level                    = default_log_level
      self.logger_name                  = default_logger_name
      self.view_path                    = default_view_path
      self.controller_paths             = default_controller_paths
      self.preload_frameworks           = default_preload_frameworks
      self.cache_classes                = default_cache_classes
      self.dependency_loading           = default_dependency_loading
      self.whiny_nils                   = default_whiny_nils
      self.plugins                      = default_plugins
      self.plugin_paths                 = default_plugin_paths
      self.plugin_locators              = default_plugin_locators
      self.plugin_loader                = default_plugin_loader
      self.database_configuration_file  = default_database_configuration_file
      self.routes_configuration_file    = default_routes_configuration_file
      self.gems                         = default_gems
      self.i18n                         = default_i18n

      self.active_support = Divinity::OrderedOptions.new
    end

    # Set the root_path to DIVINITY_ROOT and canonicalize it.
    def set_root_path!
      raise 'DIVINITY_ROOT is not set' unless defined?(::DIVINITY_ROOT)
      raise 'DIVINITY_ROOT is not a directory' unless File.directory?(::DIVINITY_ROOT)

      @root_path =
        # Pathname is incompatible with Windows, but Windows doesn't have
        # real symlinks so File.expand_path is safe.
        if RUBY_PLATFORM =~ /(:?mswin|mingw)/
          File.expand_path(::DIVINITY_ROOT)

        # Otherwise use Pathname#realpath which respects symlinks.
        else
          Pathname.new(::DIVINITY_ROOT).realpath.to_s
        end

      Object.const_set(:RELATIVE_DIVINITY_ROOT, ::DIVINITY_ROOT.dup) unless defined?(::RELATIVE_DIVINITY_ROOT)
      ::DIVINITY_ROOT.replace @root_path
    end

    # Enable threaded mode. Allows concurrent requests to controller actions and
    # multiple database connections. Also disables automatic dependency loading
    # after boot, and disables reloading code on every request, as these are
    # fundamentally incompatible with thread safety.
    def threadsafe!
      self.preload_frameworks = true
      self.cache_classes = true
      self.dependency_loading = false
      self.action_controller.allow_concurrency = true
      self
    end

    # Loads and returns the contents of the #database_configuration_file. The
    # contents of the file are processed via ERB before being sent through
    # YAML::load.
    def database_configuration
      require 'erb'
      YAML::load(ERB.new(IO.read(database_configuration_file)).result)
    end

    # The path to the current environment's file (<tt>development.rb</tt>, etc.). By
    # default the file is at <tt>config/environments/#{environment}.rb</tt>.
    def environment_path
      "#{root_path}/config/environments/#{environment}.rb"
    end

    # Return the currently selected environment. By default, it returns the
    # value of the DIVINITY_ENV constant.
    def environment
      ::DIVINITY_ENV
    end

    # Adds a block which will be executed after divinity has been fully initialized.
    # Useful for per-environment configuration which depends on the framework being
    # fully initialized.
    def after_initialize(&after_initialize_block)
      after_initialize_blocks << after_initialize_block if after_initialize_block
    end

    # Returns the blocks added with Configuration#after_initialize
    def after_initialize_blocks
      @after_initialize_blocks ||= []
    end

    # Add a preparation callback that will run before every request in development
    # mode, or before the first request in production.
    #
    # See Dispatcher#to_prepare.
    def to_prepare(&callback)
      after_initialize do
        require 'dispatcher' unless defined?(::Dispatcher)
        Dispatcher.to_prepare(&callback)
      end
    end

    def middleware
      require 'action_controller'
      ActionController::Dispatcher.middleware
    end

    def divinity_frameworks
      %w(active_support opengl RMagick log4r rubigen sdl gl glu)
    end

    def framework_paths
      paths = divinity_frameworks.collect { |i| "#{i}/lib" }
      paths.map { |dir| "#{framework_root_path}/#{dir}" }.select { |dir| File.directory?(dir) }
    end

    private
      def framework_root_path
        defined?(::DIVINITY_FRAMEWORK_ROOT) ? ::DIVINITY_FRAMEWORK_ROOT : "#{root_path}/vendor/divinity"
      end

      def default_frameworks
        %w(active_support opengl RMagick log4r rubigen sdl gl glu)
      end

      def default_load_paths
        paths = []

        # Add the old mock paths only if the directories exists
        paths.concat(Dir["#{root_path}/test/mocks/#{environment}"]) if File.exists?("#{root_path}/test/mocks/#{environment}")

        # Add the app's controller directory
        paths.concat(Dir["#{root_path}/app/controllers/"])

        # Followed by the standard includes.
        paths.concat %w(
          app
          app/models
          app/controllers
          app/helpers
          app/services
          lib
          vendor
        ).map { |dir| "#{root_path}/#{dir}" }.select { |dir| File.directory?(dir) }
      end

      # Doesn't matter since plugins aren't in load_paths yet.
      def default_load_once_paths
        []
      end

      def default_eager_load_paths
        %w(
          app/models
          app/controllers
          app/helpers
        ).map { |dir| "#{root_path}/#{dir}" }.select { |dir| File.directory?(dir) }
      end

      def default_log_path
        File.join(root_path, 'log', "#{environment}.log")
      end

      def default_log_level
        environment == 'production' ? :info : :debug
      end

      def default_logger_name
        File.basename(File.expand_path(DIVINITY_ROOT)).gsub(/(^|[\s_]+)(.)/) { $~[2].upcase }
      end

      def default_database_configuration_file
        File.join(root_path, 'config', 'database.yml')
      end

      def default_routes_configuration_file
        File.join(root_path, 'config', 'routes.rb')
      end

      def default_view_path
        File.join(root_path, 'app', 'views')
      end

      def default_controller_paths
        paths = [File.join(root_path, 'app', 'controllers')]
        paths
      end

      def default_dependency_loading
        true
      end

      def default_preload_frameworks
        false
      end

      def default_cache_classes
        true
      end

      def default_whiny_nils
        false
      end

      def default_plugins
        nil
      end

      def default_plugin_paths
        ["#{root_path}/vendor/plugins"]
      end

      def default_plugin_locators
        locators = []
        locators << Plugin::GemLocator if defined? Gem
        locators << Plugin::FileSystemLocator
      end

      def default_plugin_loader
        Plugin::Loader
      end

      def default_cache_store
        if File.exist?("#{root_path}/tmp/cache/")
          [ :file_store, "#{root_path}/tmp/cache/" ]
        else
          :memory_store
        end
      end

      def default_gems
        []
      end

      def default_i18n
        i18n = Divinity::OrderedOptions.new
        i18n.load_path = []

        if File.exist?(File.join(DIVINITY_ROOT, 'config', 'locales'))
          i18n.load_path << Dir[File.join(DIVINITY_ROOT, 'config', 'locales', '*.{rb,yml}')]
          i18n.load_path.flatten!
        end

        i18n
      end
  end
end
