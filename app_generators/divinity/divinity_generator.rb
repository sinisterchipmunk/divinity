require 'rbconfig'
require 'rubygems'
gem 'rubigen'
require 'rubigen'
require File.join(File.dirname(__FILE__), "../../lib/divinity/version.rb")

class DivinityGenerator < RubiGen::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  default_options   :shebang => DEFAULT_SHEBANG
  attr_reader :app_name, :module_name, :class_name, :file_name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = args.shift
    @app_name     = File.basename(File.expand_path(@destination_root))
    @module_name  = app_name.camelize
    @class_name   = @module_name
    @file_name    = app_name.underscore
  end

  def manifest
    # Use /usr/bin/env if no special shebang was specified
    script_options     = { :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang] }
    windows            = (RUBY_PLATFORM =~ /dos|win32|cygwin/i) || (RUBY_PLATFORM =~ /(:?mswin|mingw)/)

    record do |m|
      # Root directory and all subdirectories.
      m.directory ''
      DIRS.each { |f| m.directory f }
      m.directory "app/views/#{module_name.underscore}"

      # templates
      m.template "winapp.cmd",                                 "#{file_name}.cmd", :assigns => { :filename => file_name }
      m.template "Rakefile",                                   "Rakefile"
      m.template "application.rb",                             "#{file_name}.rb",  script_options
      m.template "app/controllers/application_controller.rb",  "app/controllers/application_controller.rb"
      m.template "app/helpers/application_helper.rb",          "app/helpers/application_helper.rb"
      m.template "app/controllers/controller.rb",              "app/controllers/#{file_name}_controller.rb"
      m.template "app/helpers/helper.rb",                      "app/helpers/#{file_name}_helper.rb"
      m.template "app/views/application/_framerate.rb",        "app/views/#{file_name}/_framerate.rb"
      m.template "app/views/application/index.rb",             "app/views/#{file_name}/index.rb"
      m.template "config/environments/development.rb",         "config/environments/development.rb"
      m.template "config/environments/production.rb",          "config/environments/production.rb"
      m.template "config/environments/test.rb",                "config/environments/test.rb"
      m.template "config/initializers/backtrace_silencers.rb", "config/initializers/backtrace_silencers.rb"
      m.template "config/initializers/inflections.rb",         "config/initializers/inflections.rb"
      m.template "config/boot.rb",                             "config/boot.rb"
      m.template "config/environment.rb",                      "config/environment.rb"
      m.template "test/test_helper.rb",                        "test/test_helper.rb"
      m.template "test/functional/controller.rb",              "test/functional/#{file_name}_test.rb"

      # static files
      m.file_copy_each %w(README config/locales/en.yml doc/README_FOR_APP log/development.log log/production.log
                          log/test.log resources/resource_map.yml)

      # scripts
      %w(console destroy generate plugin).each do |file|
        m.template "script/#{file}", "script/#{file}", script_options
        m.template "script/winscript.cmd", "script/#{file}.cmd", :assigns => { :filename => file } if windows
      end
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
    resources/actors
    script
    test/functional
    test/unit
    tmp/cache
    vendor/mods
    vendor/plugins
  )
end
