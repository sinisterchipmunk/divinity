module Engine::ContentLoader
  # Iterates through each active ContentModule and searches its base path for the specified file.
  # As a last resort, looks for the file in "data/#{filename}".
  # The last ContentModule loaded has the highest priority and will be searched first.
  def find_file(*filenames)
    locations = [ ]
    filenames.flatten!
    filenames.each do |filename|
      return filename if File.file? filename
      locations << filename
      unless filename =~ /^([\/\\]|.:[\/\\])/ # don't treat absolute paths as relative ones
        # Search the user-defined overrides first
        fi = File.join(DIVINITY_ROOT, 'data/override', filename)
        return fi if File.file? fi
        locations << fi

        load_content! unless @content_modules
        # Order is reversed because we want the LAST plugin loaded to override any preceding it
        @content_modules.reverse.each do |cm|
          fi = File.join(cm.base_path, filename)
          return fi if File.file? fi
          locations << fi
        end
      end

      # See if it turns up if we stick an extension on the end
      filenames << "#{filename}.rb" unless filename =~ /\.rb$/
    end

    sentence = locations.to_sentence
    raise "Could not find file! Looked in #{sentence}"
  end

  # Takes a pattern or series of patterns and searches for their occurrance in each registered ContentModule
  def glob_files(*paths)
    load_content! unless @content_modules
    matches = []
    paths.flatten.each do |path|
      @content_modules.reverse.each do |cm|
        matches += Dir.glob(File.join(cm.base_path, path))
      end
    end
    matches.uniq
  end

  def load_content!
    Resource::Base.remove_resource_hooks!(self)
    @content_modules = []

    # Theoretically, the options hash contains a list of modules to load, and they should be loaded in order of
    # appearance. If this is not the case, create them from the plugin index loaded earlier. Whatever order they
    # were detected in, that's the default load order.
    options[:module_load_order] ||= Engine::ContentLoader.detected_content_modules

    logger.debug "Content plugin load order:"
    options[:module_load_order].each { |i| logger.debug("  #{i}") }
    
    options[:module_load_order].each do |mod|
      logger.info "Loading plugin: #{mod}"
      mod = Engine::ContentModule.new(mod, self)
      @content_modules << mod
      Resource::Base.add_resource_hooks!(self) # this is safe to call multiple times.
      mod.load_resources!
    end

    # After content has been loaded and the rest of engine initialization has completed,
    # we need to transfer the user to the main old.
    after_initialize do
      c = self.current_controller || Engine::Controller::Base.root
      assume_interface(c) if c
    end

    logger.debug "Content ready."
  end

  def self.included(base)
    base.send(:attr_reader,   :content_modules)
    base.send(:attr_accessor, :current_controller)
    detected_content_modules
  end

  def self.detected_content_modules
    return @content_module_index if @content_module_index
    
    # Index the available modules. Note that this does not actually load them, only creates a list of those available.
    # This affords the user an opportunity to disable or reorder the modules.
    @content_module_index = [ File.join(DIVINITY_GEM_ROOT, "engine") ] +
                            [ DIVINITY_ROOT ] +
                            Dir.glob(File.join(DIVINITY_ROOT, "vendor/mods", "*"))

    Divinity.system_logger.debug "Detected content modules:"
    @content_module_index.each { |i| Divinity.system_logger.debug "  #{i}" }
  end
end
