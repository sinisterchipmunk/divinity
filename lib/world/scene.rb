module World
  class Scene
    attr_reader :gravitational_field
    attr_accessor :objects

    delegate :gravity_at, :to => :gravitational_field
    
    def initialize
      @gravitational_field = Physics::Gravity::GravitationalField.new
      @objects = [ ]
      @last_time = Time.now
    end

    # delta is the change in time, in milliseconds, since the last call to #update
    def update(delta)
      delta_in_seconds = delta / 1000.0
      objects.each do |o|
        o.update(delta, self)
      end
    end
    
    def render
      objects.each { |o| o.render }
    end
  end
end
