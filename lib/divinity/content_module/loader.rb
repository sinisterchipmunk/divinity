require "divinity/content_module"

module Divinity
  class ContentModule
    class Loader
      def initialize(divinity_initializer)
        @initializer = divinity_initializer
        @loaded_mods = []
      end

      def loaded_content_modules
        @loaded_mods
      end

      def load_modules
        module_paths.each do |path|
          @loaded_mods << ContentModule.load(path)
        end
      end

      def module_paths
        [ "#{DIVINITY_FRAMEWORK_ROOT}/builtin/resources",
          "#{DIVINITY_ROOT}/resources" ] + Dir.glob(File.join(@initializer.configuration.content_module_paths, "*"))
      end
    end
  end
end
