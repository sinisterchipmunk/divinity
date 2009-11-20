# A ContentModule is a "module" (or plugin) that contains data to be loaded into Divinity.
#
class Engine::ContentModule
  # The base path from which this ContentModule will load its data.
  attr_reader :base_path

  # The name of this ContentModule, inferred from the base path.
  attr_reader :module_name

  # The specific DivinityEngine instance this ContentModule will be applied to.
  attr_reader :engine
  
  def initialize(base_path, engine)
    @base_path = base_path
    @module_name = File.basename(base_path)
    @engine = engine

    load :routes, :abilities, :actors, :character_classes, :feats, :interfaces, :languages, :races,
         :skills, :spells, :themes
  end

  private
  def load(*what)
    what.each do |f|
      puts "#{module_name}: loading #{f}..." if $VERBOSE
      self.send("load_#{f}")
    end
  end

  def load_routes
    if File.exist?(File.join(base_path, "routes.rb"))
      require_dependency File.join(base_path, "routes.rb")
    end
  end
end
