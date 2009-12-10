module Engine::ContentModule::ClassMethods
  def resource_loaders
    @resource_loaders ||= []
  end

  def add_resource_loader(name)
    resource_loaders << name
    line = __LINE__+2
    code = <<-end_code
      self.send(:define_method, :#{name}) do
        @#{name} || HashWithIndifferentAccess.new
      end

      self.send(:define_method, :load_#{name}!) do
        @#{name} ||= HashWithIndifferentAccess.new
        dirs = Dir.glob(File.join(base_path, 'resources/#{name}/**/*.rb'))
        logger.debug "    Loading resource: #{name}" unless dirs.empty?
        dirs.each do |fi|
          logger.debug "      #{name.to_s.singularize}: \#{fi}"
          next if File.directory? fi or fi =~ /\.svn/
          eval File.read(fi), engine.send(:binding), fi, 1
        end
      end

      private :load_#{name}!
    end_code
    eval code, binding, __FILE__, line
  end

  def remove_resource_loader(name)
    resource_loaders.delete name
    self.send(:remove_method, name)           if self.respond_to?(name)
    self.send(:remove_method, "load_#{name}") if self.respond_to?("load_#{name}")
  end
end