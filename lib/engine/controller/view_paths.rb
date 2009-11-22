class Engine::Controller::ViewPaths < Array
  def initialize(*a, &b)
    super
  end

  # Returns a file path for the first matching view in this array.
  def find_view(name)
    fi = nil
    self.each do |path|                               
      if File.file?(fi = File.join(path, "#{name}.rb"))
        return fi
      elsif File.directory?(fi)
        raise "View path is a directory! (#{fi})"
      end
    end
    raise Engine::View::MissingInterfaceError, "No view found for action: #{name} in view path #{self.inspect}"
  end
end