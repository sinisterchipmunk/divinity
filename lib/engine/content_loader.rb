module Engine::ContentLoader
  def load_content!
    # Theoretically, the options hash contains a list of modules to load, and they should be loaded in order of
    # appearance. If this is not the case, create them from the module index loaded earlier. Whatever order they
    # were detected in, that's the default load order.
    options[:module_load_order] ||= Engine::ContentLoader.instance_variable_get("@modules")
    options[:module_load_order].each do |mod|
      puts "Loading module: #{mod}" if $VERBOSE
      Engine::ContentModule.new(mod, self)
    end
  end

  def self.included(base)
    # Index the available modules. Note that this does not actually load them, only creates a list of those available.
    # This affords the user an opportunity to disable or reorder the modules.
    @modules = Dir.glob(File.join(ENV['DIVINITY_ROOT'], "vendor/modules", "*"))
  end
end
