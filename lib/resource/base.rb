module Resource::Base
  @@content_types = {
    :themes => Interface::Theme,
    :images => Resource::Image,
    :actors => Resource::World::Actor,
  }.with_indifferent_access

  include Helpers::AttributeHelper
  attr_reader :engine
  random_access_attr :id, :name, :description

  def initialize(id, engine, &block)
    @id = id
    @engine = engine

    name @id.to_s.titleize
    description "No description."

    revert_to_defaults!
    yield_with_or_without_scope(&block) if block_given?
  end

  def revert_to_defaults!
  end

  def respond_to?(*args, &block)
    super or engine.respond_to? *args, &block
  end

  def method_missing(*args, &block)
    engine.send(*args, &block)
  end

  class << self
    def content_type(name, klass = nil)
      if klass.nil?
        return @@content_types[name]
      else
        return @@content_types[name] = klass
      end
    end

    def content_types
      @@content_types
    end

    def create_resource_hooks(engine)
      @@content_types.each do |plural, klass|
        class_name = klass.name
        singular = plural.to_s.singularize

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
end
