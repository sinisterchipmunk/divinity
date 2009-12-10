module Resource::ClassMethods
#  @@content_types = {
#    #:themes => Interface::Theme,
#    #:images => Resource::Image,
#    #:actors => Resource::World::Actor,
#  }.with_indifferent_access

  def load_paths
    @load_paths ||= [ File.join(DIVINITY_GEM_ROOT, "engine/models/resources") ]
  end

  def content_types
    @content_types ||= { }.with_indifferent_access
  end

  def inherited(base)
    content_types[base.name.demodulize.underscore] = base
  end

  def content_type(name, klass = nil)
    if klass.nil?
      return content_types[name]
    else
      return content_types[name] = klass
    end
  end

  def create_resource_hooks(engine)
    load_paths.each do |load_path|
      Dir[File.join(load_path, "**", "*.rb")].each do |fi|
        next unless File.file?(fi)
        require_dependency(fi)
      end
    end

    content_types.each do |name, klass|
      plural = name.pluralize
      class_name = klass.name
      singular = plural.to_s.singularize
      Engine::ContentModule.add_resource_loader(plural)

      line = __LINE__ + 2
      code = <<-end_code
        def #{singular}(id, *args, &block)
          r = self.#{plural}[id]
          if r.nil? then r = self.#{plural}[id] = #{class_name}.new(id, self, *args)
          elsif args.length > 0 then r = r.with_args(*args)
          end
          r.instance_eval(&block) if block_given?
          r
        end

        def #{plural}
          unless @#{plural}
            @#{plural} = HashWithIndifferentAccess.new
            content_modules.each do |mod|
              @#{plural}.merge!(mod.#{plural})
            end
          end
          @#{plural}
        end
      end_code
      eval code, engine.send(:binding), __FILE__, line # so we can track the line number
    end
  end
end
  