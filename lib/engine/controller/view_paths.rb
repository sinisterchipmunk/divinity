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
    cache_key = "view-file:#{name}"
    c = Divinity.cache.read(cache_key)
    return c if c
    Divinity.cache.write(cache_key, r = engine.find_file(self.collect { |path| File.join(path, name) }))
    r
  rescue
    raise Engine::View::MissingViewError, $!.message#"No view found for action: #{name} in view path #{self.inspect}"
  end
end