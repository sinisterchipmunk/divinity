# This plugin is included to Engine::View::Base by default and generates helper methods to assist with adding and laying
# out components. It searches the Components namespace for all inheritors of Components::ComponentController, generating
# the helper methods automatically. That way, each usage is identical for all components unless it is explicitly
# overridden elsewhere.
#

module Helpers::ComponentHelper
  Dir.glob(File.join(DIVINITY_GEM_ROOT, "engine/app/interface/controllers/components/*.rb")).each do |fi|
    next unless File.file?(fi) and not fi =~ /\.svn/
    require_dependency fi
  end

  def get_layout_arguments(args)
    if layout then args.slice!(0, layout.method(:add_layout_component).arity.abs - 1)
    else nil
    end
  end

  Components.constants.each do |const|
    const = Components.const_get(const)
    if const.respond_to? :controller_name
      line = __LINE__ + 2
      code = <<-end_code
        def #{const.controller_name}(*args, &block)
          layout_arguments = get_layout_arguments(args)
          request = Engine::Controller::Request.new(engine, Geometry::Rectangle.new(0,0,1,1), *args, &block)
          comp = #{const.name}.new(engine, request, Engine::Controller::Response.new)
          comp.parent = controller
          layout.add_layout_component(comp, *layout_arguments) if layout
        end
      end_code
      eval(code, binding, __FILE__, line)
    end
  end
end
