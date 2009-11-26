# Yeah, the vast majority of this file was blatantly and brutally ripped out of the Ruby on Rails source code and
# then modified to suit DivinityEngine controllers. On the other hand, that should add some familiarity for you :)
#
module Engine::Controller::Helpers
  def self.included(base)
    # Initialize the base module to aggregate its helpers.
    base.class_inheritable_accessor :master_helper_module
    base.master_helper_module = Module.new

    # Set the default directory for helpers
    base.class_inheritable_accessor :helpers_dirs
    base.helpers_dirs = [ENV['DIVINITY_ROOT']?"#{ENV['DIVINITY_ROOT']}/engine/helpers":"engine/helpers"]

    # Extend base with class methods to declare helpers.
    base.extend(Engine::Controller::Helpers::ClassMethods)

    base.class_eval do
      # Wrap inherited to create a new master helper module for subclasses.
      class << self
        alias_method_chain :inherited, :helper
      end
    end
  end

  module ClassMethods
    def dump_events
      define_method :dump_events do true end
    end

    # Causes all methods listed to silently redirect to the specified action.
    # Example:
    #   redirect :mouse_moved, :mouse_dragged, :to => :some_movement
    #
    def redirect(*actions)
      options = actions.extract_options!
      to = options.delete :to
      raise "Expected a :to option to point to an action" unless to
      actions.each do |action|
        define_method action do
          redirect_to :action => to
        end
      end
    end

    # Makes all the (instance) methods in the helper module available to views rendered through this controller.
    def add_template_helper(helper_module) #:nodoc:
      master_helper_module.module_eval { include helper_module }
    end

    # The +helper+ class method can take a series of helper module names, a block, or both.
    #
    # * <tt>*args</tt>: One or more modules, strings or symbols, or the special symbol <tt>:all</tt>.
    # * <tt>&block</tt>: A block defining helper methods.
    #
    # ==== Examples
    # When the argument is a string or symbol, the method will provide the "_helper" suffix, require the file
    # and include the module in the template class.  The second form illustrates how to include custom helpers
    # when working with namespaced controllers, or other cases where the file containing the helper definition is not
    # in one of Divinity's standard load paths:
    #   helper :foo             # => requires 'foo_helper' and includes FooHelper
    #   helper 'resources/foo'  # => requires 'resources/foo_helper' and includes Resources::FooHelper
    #
    # When the argument is a module it will be included directly in the view class.
    #   helper FooHelper # => includes FooHelper
    #
    # When the argument is the symbol <tt>:all</tt>, the controller will include all helpers beneath
    # <tt>Engine::Controller::Base.helpers_dirs</tt> (defaults to <tt>engine/helpers/**/*.rb</tt> under DIVINITY_ROOT).
    #   helper :all
    #
    # Additionally, the +helper+ class method can receive and evaluate a block, making the methods defined available
    # to the template.
    #   # One line
    #   helper { def hello() "Hello, world!" end }
    #   # Multi-line
    #   helper do
    #     def foo(bar)
    #       "#{bar} is the very best"
    #     end
    #   end
    #
    # Finally, all the above styles can be mixed together, and the +helper+ method can be invoked with a mix of
    # +symbols+, +strings+, +modules+ and blocks.
    #   helper(:three, BlindHelper) { def mice() 'mice' end }
    #
    def helper(*args, &block)
      args.flatten.each do |arg|
        case arg
          when Module
            add_template_helper(arg)
          when :all
            helper(all_application_helpers)
          when String, Symbol
            file_name  = arg.to_s.underscore + '_helper'
            class_name = file_name.camelize

            begin
              require_dependency(file_name)
            rescue LoadError => load_error
              requiree = / -- (.*?)(\.rb)?$/.match(load_error.message).to_a[1]
              if requiree == file_name
                msg = "Missing helper file #{file_name}.rb"
                raise LoadError.new(msg).copy_blame!(load_error)
              else
                raise
              end
            end

            add_template_helper(class_name.constantize)
          else
            raise ArgumentError, "helper expects String, Symbol, or Module argument (was: #{args.inspect})"
        end
      end

      # Evaluate block in template class if given.
      master_helper_module.module_eval(&block) if block_given?
    end

    # Declare a controller method as a helper. For example, the following
    # makes the +current_user+ controller method available to the view:
    #   class ApplicationController < Engine::Controller::Base
    #     helper_method :current_user, :logged_in?
    #
    #     def current_user
    #       @current_user ||= User.find_by_id(session[:user])
    #     end
    #
    #      def logged_in?
    #        current_user != nil
    #      end
    #   end
    #
    # In a view:
    #  <% if logged_in? -%>Welcome, <%= current_user.name %><% end -%>
    def helper_method(*methods)
      methods.flatten.each do |method|
        master_helper_module.module_eval <<-end_eval
          def #{method}(*args, &block)                    # def current_user(*args, &block)
            controller.send(%(#{method}), *args, &block)  #   controller.send(%(current_user), *args, &block)
          end                                             # end
        end_eval
      end
    end

    # Declares helper accessors for controller attributes. For example, the
    # following adds new +name+ and <tt>name=</tt> instance methods to a
    # controller and makes them available to the view:
    #   helper_attr :name
    #   attr_accessor :name
    def helper_attr(*attrs)
      attrs.flatten.each { |attr| helper_method(attr, "#{attr}=") }
    end

    # Provides a proxy to access helpers methods from outside the view.
    def helpers
      unless @helper_proxy
        @helper_proxy = Engine::View::Base.new(self)
        @helper_proxy.extend master_helper_module
      else
        @helper_proxy
      end
    end

    private
      def default_helper_module!
        unless name.blank?
          module_name = name.sub(/Controller$|$/, 'Helper')
          module_path = module_name.split('::').map { |m| m.underscore }.join('/')
          require_dependency module_path
          helper module_name.constantize
        end
      rescue MissingSourceFile => e
        raise unless e.is_missing? module_path
      rescue NameError => e
        raise unless e.missing_name? module_name
      end

      def inherited_with_helper(child)
        inherited_without_helper(child)

        begin
          child.master_helper_module = Module.new
          child.master_helper_module.__send__ :include, master_helper_module
          child.__send__ :default_helper_module!
        rescue MissingSourceFile => e
          raise unless e.is_missing?("helpers/#{child.controller_path}_helper")
        end
      end

      # Extract helper names from files in app/helpers/**/*.rb
      def all_application_helpers
        map = []
        helpers_dirs.each do |helpers_dir|
          extract = /^#{Regexp.quote(helpers_dir)}\/?(.*)_helper.rb$/
          map += Dir["#{helpers_dir}/**/*_helper.rb"].map { |file| file.sub extract, '\1' }
        end
        map
      end
  end
end