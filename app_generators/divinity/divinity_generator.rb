require 'rbconfig'
require 'rubygems'
gem 'rubigen'
require 'rubigen'
require File.join(File.dirname(__FILE__), "../../lib/divinity/version.rb")

class DivinityGenerator < RubiGen::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  default_options   :shebang => DEFAULT_SHEBANG
  attr_reader :app_name, :module_name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = args.shift
    @app_name     = File.basename(File.expand_path(@destination_root))
    @module_name  = app_name.camelize
  end

  def manifest
    # Use /usr/bin/env if no special shebang was specified
    script_options     = { :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang] }
    #windows            = (RUBY_PLATFORM =~ /dos|win32|cygwin/i) || (RUBY_PLATFORM =~ /(:?mswin|mingw)/)

    assigns = { :assigns => {
      :module_name => module_name,
      :app_name => app_name
    } }

    script_options.merge! assigns

    record do |m|
      # Root directory and all subdirectories.
      m.directory ''
      DIRS.each { |f| m.directory f }
      m.directory "app/views/#{module_name.underscore}"

      # Test helper
      m.template "Rakefile",                                   "Rakefile", assigns
      m.template "application.rb",                             "#{module_name.underscore}.rb",  script_options
      m.template "app/controllers/application.rb",             "app/controllers/application_controller.rb",  script_options
      m.template "app/controllers/application_controller.rb",  "app/controllers/#{module_name.underscore}_controller.rb", assigns
      m.template "app/views/application/_framerate.rb",        "app/views/#{module_name.underscore}/_framerate.rb", assigns
      m.template "app/views/application/index.rb",             "app/views/#{module_name.underscore}/index.rb", assigns
      m.file     "README",                                     "README", assigns
      m.template "config/environments/development.rb",         "config/environments/development.rb", assigns
      m.template "config/environments/production.rb",          "config/environments/production.rb", assigns
      m.template "config/environments/test.rb",                "config/environments/test.rb", assigns
      m.template "config/initializers/backtrace_silencers.rb", "config/initializers/backtrace_silencers.rb", assigns
      m.template "config/initializers/inflections.rb",         "config/initializers/inflections.rb", assigns
      m.file     "config/locales/en.yml",                      "config/locales/en.yml", assigns
      m.template "config/boot.rb",                             "config/boot.rb", assigns
      m.template "config/environment.rb",                      "config/environment.rb", assigns
      m.file     "doc/README_FOR_APP",                         "doc/README_FOR_APP", assigns
      m.file     "log/development.log",                        "log/development.log", assigns
      m.file     "log/production.log",                         "log/production.log", assigns
      m.file     "log/test.log",                               "log/test.log", assigns
      m.template "script/about",                               "script/about",     script_options
      m.template "script/console",                             "script/console",   script_options
      m.template "script/destroy",                             "script/destroy",   script_options
      m.template "script/generate",                            "script/generate",  script_options
      m.template "script/plugin",                              "script/plugin",    script_options
      m.template "test/test_helper.rb",                        "test/test_helper.rb", assigns
    end
  end

  protected
    def banner
      "Usage: #{File.basename $0} /path/to/your/app [options]"
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator "#{File.basename $0} options:"
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

  # Installation skeleton.  Intermediate directories are automatically
  # created so don't sweat their absence here.
  DIRS = %w(
    app/controllers
    app/helpers
    app/models
    app/views
    config/environments
    config/initializers
    config/locales
    doc
    lib/tasks
    log
    resources
    script
    test/fixtures
    test/functional
    test/unit
    tmp/cache
    vendor/mods
  )
end
