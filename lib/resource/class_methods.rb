module Resource::ClassMethods
#  @@content_types = {
#    #:themes => Interface::Theme,
#    #:images => Resource::Image,
#    #:actors => Resource::World::Actor,
#  }.with_indifferent_access

  def load_paths
    @load_paths ||= [ "app/resource" ]
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
    engine.glob_files(load_paths.collect { |i| File.join(i, "**/*.rb") }).each do |fi|
      next unless File.file?(fi)
      require_dependency(fi)
    end

    content_types.each do |name, klass|
      plural = name.pluralize
      class_name = klass.name
      singular = plural.singularize
      Engine::ContentModule.add_resource_loader(plural)

      line = __LINE__ + 2
      code = <<-end_code
        def engine.#{singular}(id, *args, &block)
          r = self.#{plural}[id]
          if r.nil? then r = self.#{plural}[id] = #{class_name}.new(id, self, *args)
          elsif args.length > 0 then r = r.with_args(*args)
          end
          r.instance_eval(&block) if block_given?
          r
        end

        def engine.#{plural}(id = nil, *args, &block)
          return #{singular}(id, *args, &block) unless id.nil?
          unless @#{plural}
            @#{plural} = HashWithIndifferentAccess.new
            content_modules.each do |mod|
              @#{plural}.merge!(mod.#{plural})
            end
          end
          @#{plural}
        end
      end_code
      eval code, binding, __FILE__, line # so we can track the line number
    end
  end
end
  