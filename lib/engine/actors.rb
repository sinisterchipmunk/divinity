module Engine::Actors
  def actor(id)
    self.actors[id]
  end

  def actors
    if @actors.nil?
      # Load actors
      @actors ||= HashWithIndifferentAccess.new
      Dir.glob("actors/**/*.rb").each do |fi|
        next if File.directory? fi or fi =~ /\.svn/
        eval File.read(fi), binding, fi, 1
      end
    end
    @actors
  end

  def add_actor(id, &block)
    @actors[id] = World::Actor.new(id, &block) 
  end
end
