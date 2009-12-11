module Resource::ClassMethods
#  @@content_types = {
#    #:themes => Interface::Theme,
#    #:images => Resource::Image,
#    #:actors => Resource::World::Actor,
#  }.with_indifferent_access

  def load_paths
    @load_paths ||= [ "app/models" ]
  end

  def content_types
    @content_types ||= { }.with_indifferent_access
  end

  def register_content_type(klass = nil)
    # We do it this way because it SEEMS to be maintaining different hashes for different subclasses.
    # My mind is a bit fuzzy right now, but I think that makes sense. Multiple instances of Class or some such.
    # In any case, this makes all content type registrations explicit, routing them directly into Resource::Base.
    if klass.nil?
      Resource::Base.register_content_type(self)
    else
      content_types[klass.name.demodulize.underscore] = klass
    end
  end

  def content_type(name, klass = nil)
    if klass.nil?
      return content_types[name]
    else
      return content_types[name] = klass
    end
  end

  def remove_resource_hooks!(engine)
    each_resource_hook do |name, klass, singular, plural, class_name|
      Divinity.system_logger.debug "Removing resource hook: #{name} => #{klass}"
      content_types.delete(name)
      Engine::ContentModule.remove_resource_loader(plural)
      engine.instance_eval "undef #{singular}" if engine.respond_to?(singular)
      engine.instance_eval "undef #{plural}"   if engine.respond_to?(plural)
    end
  end

  def add_resource_hooks!(engine)
    each_resource_hook do |name, klass, singular, plural, class_name|
      next if Engine::ContentModule.resource_loaders.include?(plural)
      Divinity.system_logger.debug "      Adding resource hook: #{name} => #{klass}"

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

  def each_resource_hook
    content_types.each do |name, klass|
      plural = name.pluralize
      class_name = klass.name
      singular = plural.singularize
      yield name, klass, singular, plural, class_name
    end
  end
end
  