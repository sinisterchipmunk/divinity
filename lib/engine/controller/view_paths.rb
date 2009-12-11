class Engine::Controller::ViewPaths < Array
  def self.default_view_paths=(view_paths)
    view_paths = [ view_paths ] unless view_paths.kind_of? Array
    default_view_paths = view_paths
  end

  def self.default_view_paths
    @default_view_paths ||= []
  end

  def self.load!
    # may use this to get away from instance-based view paths and use a single class-based set instead. Hope that made
    # sense, I'm tired.
  end

  def initialize(*a, &b)
    super
    concat self.class.default_view_paths
    uniq!
    #self << "app/views" unless self.include? "app/views"
  end

  # Returns a file path for the first matching view in this array.
  def find_view(engine, name)
    fi = nil
    self.each do |path|
      return engine.find_file(File.join(path, name))
    end
  rescue
    raise Engine::View::MissingInterfaceError, $!.message#"No view found for action: #{name} in view path #{self.inspect}"
  end
end