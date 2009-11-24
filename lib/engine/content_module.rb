# A ContentModule is a "module" (or plugin) that contains data to be loaded into Divinity.
#
class Engine::ContentModule
  include Helpers::ContentHelper

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

    load :themes, :interfaces, :actors, :languages, :races, :character_classes, :images
  end

  def respond_to?(name, *args, &block)
    super(name, *args, &block) || engine.respond_to?(name, *args, &block)
  end

  def method_missing(name, *args, &block)
    engine.send(name, *args, &block) if engine.respond_to? name
    super
  end

  include Engine::Content

  [ :themes, :actors, :languages, :races, :character_classes, :images ].each do |plural|
    line = __LINE__+2
    code = <<-end_code
      def #{plural}
        @#{plural} || HashWithIndifferentAccess.new
      end

      def load_#{plural}
        @#{plural} ||= HashWithIndifferentAccess.new
        Dir.glob(File.join(base_path, '#{plural}', "**", "*.rb")).each do |fi|
          next if File.directory? fi or fi =~ /\.svn/
          eval File.read(fi), binding, fi, 1
        end
      end

      private :load_#{plural}
    end_code
    eval code, binding, __FILE__, line
  end

  private
    def load(*what)
      what.each do |f|
        puts "#{module_name}: loading #{f.to_s.humanize.downcase}..." if $VERBOSE
        self.send("load_#{f}")
      end
    end

    def load_interfaces
      controller_path = File.join(base_path, "interfaces/controllers/")
      model_path = File.join(base_path, "interfaces/models")
      view_path = File.join(base_path, "interfaces/views")
      ActiveSupport::Dependencies.load_paths << controller_path
      ActiveSupport::Dependencies.load_paths << model_path
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
