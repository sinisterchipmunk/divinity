module World
  class Scene
    attr_reader :gravitational_field
    attr_accessor :objects
    
    def initialize
      @gravitational_field = Physics::Gravity::GravitationalField.new
      @objects = [ ]
      @last_time = Time.now
    end
    
    def update
      tc = (Time.now - @last_time).to_f
      @last_time = Time.now
      objects.each do |o|
        g = @gravitational_field.gravity_at(o.position)
        o.acceleration = (g * tc * o.mass)
        o.update(self)
      end
    end
    
    def render
      objects.each { |o| o.render }
    end
  end
end
