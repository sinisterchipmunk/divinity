module Physics
  module Gravity
    BIG_G = (6.67428 * (10 ** -3))
    # accurate to real world: (6.67428 * (10 ** -11))
    
    class GravitationalField
      attr_reader :sources
      
      def initialize
        @sources = [ ]
      end
      
      #  F = G*(m1*m2)/r^2
      #  F/m2 = G*(m1*m2)/r^2 = G*m1/r^2
      #
      # Setting m2 to 1, gravity_at returns a FACTOR of the gravitational pull of an object in relation to all
      # registered gravity_sources based on the distance specified. The return value is a 3-dimensional vector.
      # Multiplied by the mass of the object at the supplied position, this vector would produce the overall
      # gravitational acceleration (NOT velocity!) on the object in question within this gravitational field at
      # this moment in time.
      #
      # Notice that we're cheating when distance == 0 because this would be a division by zero. Physicists say
      # it's undefined, but I say it's infinity, so there. In any case, it's not something we can work with, so
      # we divide by 1 instead.
      #
      def gravity_at(point)
        ret = Math::Vector.new
        sources.each do |source|
          ret += (source.position - point).to_unit * (BIG_G * source.mass /
                       (source.position.distance(point) == 0 ? 1 : source.position.distance(point).squared))
        end
        ret
      end
    end
  end
end
