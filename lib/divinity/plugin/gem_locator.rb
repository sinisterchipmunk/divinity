module Divinity
  class Plugin
    # The GemLocator scans all the loaded RubyGems, looking for gems with
    # a <tt>divinity/init.rb</tt> file.
    class GemLocator < Locator
      def plugins
        gem_index = initializer.configuration.gems.inject({}) { |memo, gem| memo.update gem.specification => gem }
        specs     = gem_index.keys
        specs    += Gem.loaded_specs.values.select do |spec|
          spec.loaded_from && # prune stubs
            File.exist?(File.join(spec.full_gem_path, "divinity", "init.rb"))
        end
        specs.compact!

        require "rubygems/dependency_list"

        deps = Gem::DependencyList.new
        deps.add(*specs) unless specs.empty?

        deps.dependency_order.collect do |spec|
          Rails::GemPlugin.new(spec, gem_index[spec])
        end
      end
    end
  end
end
