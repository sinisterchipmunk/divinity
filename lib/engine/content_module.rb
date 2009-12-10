# A ContentModule is a "module" (or plugin) that contains data to be loaded into Divinity.
#
class Engine::ContentModule
  include Helpers::ContentHelper

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

    self.class.find_available_resources(base_path)

    logger.debug "Loading resources: #{self.class.resource_loaders.to_sentence}"
    load *(self.class.resource_loaders)
  end

  def respond_to?(name, *args, &block)
    super(name, *args, &block) || engine.respond_to?(name, *args, &block)
  end

  def method_missing(name, *args, &block)
    engine.send(name, *args, &block) if engine.respond_to? name
    super
  end

  def self.resource_loaders
    @resource_loaders ||= []
  end

  def self.add_resource_loader(name)
    Divinity.logger.debug "add resource loader: #{name}"
    resource_loaders << name
    line = __LINE__+2
    code = <<-end_code
      def #{name}
        @#{name} || HashWithIndifferentAccess.new
      end

      def load_#{name}
        @#{name} ||= HashWithIndifferentAccess.new
        Dir.glob(File.join(base_path, 'app/resource/#{name}/**/*.rb')).each do |fi|
          logger.debug fi
          next if File.directory? fi or fi =~ /\.svn/
          eval File.read(fi), binding, fi, 1
        end
      end

      private :load_#{name}
    end_code
    eval code, binding, __FILE__, line
  end

  def self.find_available_resources(base_path)
    Dir.glob(File.join(base_path, "app/resource/**", "*.rb")).each do |fi|
      require_dependency fi if File.file? fi
    end
  end

  private
    def load(*what)
      what.each do |f|
        logger.debug "#{module_name}: loading #{f.to_s.humanize.downcase}..." if $VERBOSE
        self.send("load_#{f}")
      end
    end

    def add_load_once_paths(*paths)
      paths.each do |path|
        ActiveSupport::Dependencies.load_paths << path
        ActiveSupport::Dependencies.load_once_paths << path
      end
    end

    def load_interfaces
      controller_path = File.join(base_path, "app/interface/controllers/")
      model_path = File.join(base_path, "app/interface/models")
      view_path = File.join(base_path, "app/interface/views")
      app_path = File.join(base_path, "app")
      lib_path = FIle.join(base_path, "lib")

      add_load_once_paths(controller_path, model_path, app_path, lib_path)

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
