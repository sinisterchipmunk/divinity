module World
  class Object
    attr_accessor :position, :velocity, :acceleration
    attr_accessor :mass
    
    def initialize
      @position = Math::Vector.new
      @velocity = Math::Vector.new
      @acceleration = Math::Vector.new
      @mass = 1
    end

    def update(delta_in_seconds, scene)
      # Change in velocity for this duration.
      self.acceleration = (scene.gravity_at(position) * delta_in_seconds * mass)

      # Change in velocity for this duration.
      # I think this is right, but I'm no physics major. Relativity says that as an object travels faster,
      # its effective mass increases, and it takes more acceleration to go faster. In my simplified world,
      # I'm assuming that means that it can be broken down to "increase = (acceleration - velocity)". I might be
      # wrong, but it seems to work...
      self.velocity += ((self.acceleration - self.velocity) * delta_in_seconds)

      # Update position to reflect the above.
      self.position += (self.velocity * tc)
    end
  end
end
