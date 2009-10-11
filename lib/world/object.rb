module World
  class Object
    attr_accessor :position, :velocity, :acceleration
    attr_accessor :mass
    
    def initialize
      @position = Math::Vector.new
      @velocity = Math::Vector.new
      @acceleration = Math::Vector.new
      @mass = 1
      @last_time = Time.now
    end
    
    def update(scene)
      tc = (Time.now - @last_time).to_f
      @last_time = Time.now
      self.velocity += ((self.acceleration - self.velocity) * tc)
      self.position += (self.velocity * tc)
    end
  end
end