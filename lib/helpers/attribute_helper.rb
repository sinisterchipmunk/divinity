# Provides additional setter/getter builders
module Helpers::AttributeHelper
  def self.included(base)
    base.class_eval do
      def self.random_access_attr(*attrs)
        attrs.each do |name|
          line = __LINE__ + 1
          code = <<-end_code
            def #{name}(*args, &block)
              return @#{name} if args.length == 0 and not block_given?
              if args.length == 0
                @#{name} = yield_with_or_without_scope(&block)
              elsif args.length == 1
                @#{name} = args[0]
              else
                raise "Only one argument expected"
              end
              if self.respond_to? :validate
                self.validate
              end
              @#{name}
            end

            def #{name}=(v)
              @#{name} = v
              if self.respond_to? :validate
                self.validate
              end
              @#{name}
            end
          end_code
          class_eval code
        end
      end
    end
  end

  def yield_with_or_without_scope(&block)
    if block.arity == 0 or block.arity == -1 then instance_eval &block
    else yield self
    end
  end
end
