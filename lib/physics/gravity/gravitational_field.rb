module Physics
  module Gravity
    BIG_G = (6.67428 * (10 ** -3))
    # accurate to real world: (6.67428 * (10 ** -11))
    
    class GravitationalField
      attr_accessor :sources
      
      def initialize
        @sources = [ ]
      end
      
      #F = G*(m1*m2)/r^2
      #F/m2 = G*(m1*m2)/r^2 = G*m1/r^2
      #Setting m2 to 1, gravity_at returns a FACTOR of the gravitational
      #pull of an object in relation to all registered gravity_sources based
      #on the distance specified. The return value is a 3-dimensional vector.
      #Multiplied by the mass of the object at the supplied position, this
      #vector would produce the overall gravitational pull on the object
      #in question within this gravitational field.
      def gravity_at(point)
        ret = Math::Vector.new
        sources.each { |source| ret += (source.position - point).to_unit * (BIG_G * source.mass / (source.position.distance(point) == 0 ? 0 : source.position.distance(point).squared)) }
        ret
      end
    end
  end
end