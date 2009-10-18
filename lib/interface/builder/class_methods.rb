module Interface::Builder::ClassMethods
  def generic_container(*names)
    names.each do |name|
      name = name.to_s
      line = __LINE__+2
      code = <<-end_code
      def #{name}(constraints = nil, &block)
        p = Interface::Containers::#{name.camelize}.new
        self.class.new(&block).apply_to(@engine, p) if block_given?
        component.add(p, constraints)
      end
      end_code
      class_eval code, __FILE__, line
    end
  end

  def model_component(*names)
    names.each do |name|
      name = name.to_s
      line = __LINE__+2
      code = <<-end_code
      def #{name}(constraints = nil, object = nil, method = nil, options = { }, &block)
        options.merge! method and method = nil if method.kind_of? Hash
        c = Interface::Components::#{name.camelize}.new(object, method, options, &block)
        component.add c, constraints
      end
      end_code
      class_eval code, __FILE__, line
    end
  end

  def model_container(*names)
    names.each do |name|
      name = name.to_s
      line = __LINE__+2
      code = <<-end_code
      def #{name}(constraints = nil, object = nil, method = nil, options = { }, &block)
        options.merge! method and method = nil if method.kind_of? Hash
        p = Interface::Containers::#{name.camelize}.new(object, method, options)
        self.class.new(&block).apply_to(@engine, p) if block_given?
        component.add p, constraints
      end
      end_code
      class_eval code, __FILE__, line
    end
  end
end