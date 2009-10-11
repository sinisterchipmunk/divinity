module Physics
  module Gravity
    module GravitySource
      def position
        raise "A GravitySource must define position as a Vector"
      end
      
      def mass
        raise 'A GravitySource must define mass as a Float'
      end
    end
  end
end
