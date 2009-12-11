require 'rbconfig'
require 'rubygems'
gem 'rubigen'
require 'rubigen'

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

    record do |m|
      # Root directory and all subdirectories.
      m.directory ''
      DIRS.each { |f| m.directory f }

      # Test helper
      m.file     "Rakefile",                                   "Rakefile"
      m.template "application.rb",                             "application.rb",  script_options
      m.file     "README",                                     "README"
      m.file     "config/environments/development.rb",         "config/environments/development.rb"
      m.file     "config/environments/production.rb",          "config/environments/production.rb"
      m.file     "config/environments/test.rb",                "config/environments/test.rb"
      m.file     "config/initializers/backtrace_silencers.rb", "config/initializers/backtrace_silencers.rb"
      m.file     "config/initializers/inflections.rb",         "config/initializers/inflections.rb"
      m.file     "config/locales/en.yml",                      "config/locales/en.yml"
      m.file     "config/boot.rb",                             "config/boot.rb"
      m.file     "config/environment.rb",                      "config/environment.rb"
      m.file     "doc/README_FOR_APP",                         "doc/README_FOR_APP"
      m.file     "log/development.log",                        "log/development.log"
      m.file     "log/engine.log",                             "log/engine.log"
      m.file     "log/production.log",                         "log/production.log"
      m.file     "log/test.log",                               "log/test.log"
      m.template "script/about",                               "script/about",     script_options
      m.template "script/console",                             "script/console",   script_options
      m.template "script/destroy",                             "script/destroy",   script_options
      m.template "script/generate",                            "script/generate",  script_options
      m.template "script/plugin",                              "script/plugin",    script_options
      m.file     "test/test_helper.rb",                        "test/test_helper.rb"
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
