module Divinity
  class ContentModule
    attr_reader :base_path

    def initialize(base_path)
      @base_path = base_path
    end

    def load
      Divinity.system_logger.info "Loading content module #{content_module_name} (at #{base_path})"
      map_resources
      load_content unless subdirectories.empty?
      @loaded = true
    end

    def load_content
      Divinity.system_logger.debug "[#{content_module_name}] Loading content"
      subdirectories.each do |dir|
        resource_name = resource_name_for_path(dir)
        klass = resource_map[resource_name]
        entries = Dir.glob(File.join(dir, "**", "*.rb")).select { |i| File.file?(i) }
        Divinity.system_logger.debug "[#{content_module_name}/#{resource_name}] Found #{entries.length} entries"
        entries.each do |path|
          id = path.sub(/^#{Regexp::escape dir}\/(.*)\.rb$/, '\1')
          Divinity.system_logger.debug "[#{content_module_name}/#{resource_name}] Loading #{id} from #{path}"
          klass.add(klass.new(id) { eval File.read(path), binding, path, 1 })
        end
      end
    end
    private :load_content

    def map_resources
      Divinity.system_logger.debug "[#{content_module_name}] Mapping resources"
      resource_map.each do |method_name, klass|
        singular = method_name.singularize
        singular = nil if singular == method_name
        line = __LINE__ + 2
        DivinityEngine.class_eval do
          code = <<-end_code
            def #{method_name}(id = nil, *args, &block)               # def actors(id = nil, *args, &block)
              if id                                                   #   if id
                res = begin                                           #     res = begin
                  #{klass}.find(id)                                   #       Actor.find(id)
                rescue Errors::ResourceNotFound                       #     rescue Errors::ResourceNotFound
                  #{klass}.new(id, *args)                             #       Actor.new(id, *args)
                end                                                   #     end
                res.process_block(&block) if block_given?             #     res.process_block(&block) if block_given?
                res                                                   #     res
              else                                                    #   else
                #{klass}.all                                          #     Actor.all
              end                                                     #   end
            end                                                       # end
                                                                      #
            #{singular ? '' : "alias #{singular} #{method_name}"}     # alias actor actors
          end_code

          eval code, binding, __FILE__, line
        end
      end
    end
    private :map_resources

    def content_module_name
      case base_path
        when File.join(DIVINITY_ROOT, "resources") then "main"
        when File.join(DIVINITY_FRAMEWORK_ROOT, "builtin", "resources") then "engine"
        else File.basename(base_path)
      end
    end

    # Returns the list of subdirectories in this content module
    def subdirectories
      Dir.glob(File.join(base_path, "*")).reject { |i| !File.directory?(i) }
    end

    def resource_name_for_path(path)
      path.gsub /^#{Regexp::escape base_path}(\/|)/, ''
    end
    private :resource_name_for_path

    # The hash loaded from the "resource_map.yml" YAML file. This file contains a list of key-value pairs mapping method
    # names to class names. For example, a "resource_map.yml" file with the following entries:
    #   characters: Actor
    #   actors: Actor
    #   themes: Theme
    #
    # ... would map both the "characters" and "actors" methods to a collection of Actors, and the "themes" method
    # to a collection of Themes.
    #
    # Any entries not in this file will simply be inferred from the content module's directory listing. For instance,
    # if the "themes" item was omitted but a "themes" directory was found, it would be mapped to its singular form
    # (::Theme).
    def resource_map
      return @resource_map if @resource_map
      @resource_map = YAML::load(File.read(yaml_path)) if File.file?(yaml_path)
      @resource_map = {} if @resource_map.nil?
      subdirectories.each do |resource_name|
        resource_name = resource_name_for_path(resource_name)
        begin
          if @resource_map.key?(resource_name)
            @resource_map[resource_name] = @resource_map[resource_name].constantize
          else
            class_name = resource_name.singularize.camelize
            Divinity.system_logger.debug "[#{content_module_name}] " +
                  "Dynamically mapping resource hook '#{resource_name}' to class #{class_name}"
            @resource_map[resource_name] = class_name.constantize
          end
        rescue NameError
          raise Errors::ResourceMapping, "[#{content_module_name}] " +
                  "Couldn't map #{resource_name} to #{class_name}; you probably need an entry in resource_map.yml"
        end
      end
      @resource_map
    end

    # The path to the "resource_map.yml" YAML file. This file contains a list of key-value pairs mapping method names
    # to class names. For example, a "resource_map.yml" file with the following entries:
    #   characters: Actor
    #   actors: Actor
    #   themes: Theme
    #
    # ... would map both the "characters" and "actors" methods to a collection of Actors, and the "themes" method
    # to a collection of Themes.
    #
    # Any entries not in this file will simply be inferred from the content module's directory listing. For instance,
    # if the "themes" item was omitted but a "themes" directory was found, it would be mapped to its singular form
    # (::Theme).
    def yaml_path
      File.join(base_path, "resource_map.yml")
    end

    # Returns true if this content module has finished loading, false otherwise.
    def loaded?
      @loaded
    end

    class << self
      def load(base_path)
        new(base_path).load
      end
    end
  end
end
