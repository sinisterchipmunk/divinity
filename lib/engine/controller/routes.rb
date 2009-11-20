module Engine::Controller::Routes
  def self.draw(&block)
    @route_set ||= Engine::Controller::Routes::RouteSet.new
    @route_set.draw &block
  end

  def self.route_set
    @route_set
  end

  class RouteSet
    def initialize
      @routes = HashWithIndifferentAccess.new
    end
    
    def draw
      yield self
    end

    def [](a) @routes[a] end

    def root(tag = nil, options = {})
      if tag
        connect(tag, options)
        @root = tag
      end
      @root
    end

    def connect(tag, options = { })
      options[:controller] ||= tag
      options[:action] ||= 'index'

      options[:controller] = options[:controller].to_s
      options[:action]     = options[:action].to_s

      ctr = options[:controller].camelize
      ctr = "#{ctr}Controller" unless ctr.ends_with?("Controller")

      options[:controller_class] = ctr.constantize
      @routes[tag] = options
    end
  end
end
