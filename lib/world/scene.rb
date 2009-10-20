module World
  class Scene
    attr_reader :gravitational_field, :engine
    attr_accessor :objects

    delegate :gravity_at, :to => :gravitational_field
    
    def initialize(engine)
      @gravitational_field = Physics::Gravity::GravitationalField.new
      @objects = [ ]
      @last_time = Time.now
      @engine = engine
    end

    # delta is the change in time, in milliseconds, since the last call to #update
    def update(delta)
      delta_in_seconds = delta / 1000.0
      objects.each do |o|
        o.update(delta, self)
      end
    end

    # Renders the scene. First, the matrix is pushed; then identity is loaded and
    # engine.camera.look! is called, setting up the view. Then, if a block was given,
    # it yields. This way, subclasses can render components of the scene without losing
    # the engine.camera.look! matrix. Finally, all objects in the scene are rendered and
    # the matrix is popped.
    def render
      push_matrix do
        glLoadIdentity
        engine.camera.look!
        yield if block_given?
        objects.each { |o| o.render if o.respond_to? :render }
      end
    end
  end
end
