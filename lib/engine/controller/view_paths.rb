class Engine::Controller::ViewPaths < Array
  def initialize(*a, &b)
    super
    self << "app/interface/views" unless self.include? "app/interface/views"
  end

  # Returns a file path for the first matching view in this array.
  def find_view(engine, name)
    fi = nil
    self.each do |path|
      return engine.find_file(File.join(path, name))
#
#      if File.file?(fi = File.join(path, "#{name}.rb"))
#        return fi
#      elsif File.directory?(fi)
#        raise "View path is a directory! (#{fi})"
#      end
    end
  rescue
    raise Engine::View::MissingInterfaceError, $!.message#"No view found for action: #{name} in view path #{self.inspect}"
  end
end