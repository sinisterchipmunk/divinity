module Physics
  module Gravity
    module GravitySource
      def position
        raise "A GravitySource must define position as a Vector"
      end
      
      def mass
        raise 'A GravitySource must define mass'
      end
    end
  end
end
