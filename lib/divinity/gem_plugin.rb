module Divinity
  # This Plugin subclass represents a Gem plugin. Although RubyGems has already
  # taken care of $LOAD_PATHs, it exposes its load_paths to add them
  # to Dependencies.load_paths.
  class GemPlugin < Plugin
    # Initialize this plugin from a Gem::Specification.
    def initialize(spec, gem)
      directory = spec.full_gem_path
      super(directory)
      @name = spec.name
    end

    def init_path
      File.join(directory, 'rails', 'init.rb')
    end
  end
end
