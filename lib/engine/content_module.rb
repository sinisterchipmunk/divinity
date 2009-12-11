# A ContentModule contains data to be loaded into the game.
#
class Engine::ContentModule
  include Helpers::ContentHelper
  extend Engine::ContentModule::ClassMethods

  delegate :logger, :to => :engine

  # The base path from which this ContentModule will load its data.
  attr_reader :base_path

  # The name of this ContentModule, inferred from the base path.
  attr_reader :module_name

  # The specific DivinityEngine instance this ContentModule will be applied to.
  attr_reader :engine

  def initialize(base_path, engine)
    @base_path = base_path
    @module_name = File.basename(base_path)
    @engine = engine
    @resource_loaders = []

    add_load_once_paths(paths)
    find_available_resources()
  end

  def load_resources!
    logger.debug "   Loading resources: #{resource_loaders.to_sentence}"
    load *(resource_loaders)
  end

  def respond_to?(name, *args, &block)
    super(name, *args, &block) || engine.respond_to?(name, *args, &block)
  end

  def method_missing(name, *args, &block)
    engine.send(name, *args, &block) if engine.respond_to? name
    super
  end

  def paths
    [ controller_path, model_path, view_path, app_path, lib_path ]
  end

  def resource_loaders
    self.class.resource_loaders
  end

  def controller_path; File.join(base_path, "app/controllers") end
  def model_path; File.join(base_path, "app/models") end
  def view_path; File.join(base_path, "app/views") end
  def app_path; File.join(base_path, "app") end
  def lib_path; File.join(base_path, "lib") end

  # Searches {base_path}/app/models/**/*.rb for valid resources and adds a loader for each one found
  def find_available_resources()
    Divinity.system_logger.debug "   Scanning resources in #{base_path}..."
    Dir.glob(File.join(base_path, "app/models/**", "*.rb")).each do |fi|
      if File.file? fi
        klass = fi.sub(/^#{Regexp::escape File.join(base_path, "app/models")}(.*)\.rb$/, '\1').camelize.constantize
        if klass.respond_to? :register_content_type
          Divinity.system_logger.debug "      Found resource #{klass.name}"
          klass.register_content_type
        end
      end
    end
  end

  private
    def load(*what)
      what.each do |f|
        self.send("load_#{f}!")
      end
    end

    def add_load_once_paths(*paths)
      paths.flatten.each do |path|
        ActiveSupport::Dependencies.load_paths << path
        ActiveSupport::Dependencies.load_once_paths << path
      end
    end

    def load_interfaces
      Dir.glob(File.join(controller_path, "**/*.rb")).each do |fi|
        next if File.directory? fi or fi =~ /\.svn/
        # bring the controllers into existence
        fi.gsub(/^#{Regexp::escape controller_path}(.*)\.rb$/, '\1').camelize.constantize.append_view_path view_path
      end
      Dir.glob(File.join(model_path, "**/*.rb")).each do |fi|
        next if File.directory? fi or fi =~ /\.svn/
        # bring the models into existence
        fi.gsub(/^#{Regexp::escape model_path}(.*)\.rb$/, '\1').camelize.constantize
      end
    end
end
