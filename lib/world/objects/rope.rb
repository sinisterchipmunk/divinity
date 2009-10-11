module World
  module Objects
    class Rope < World::Object
      include Gl
      include Physics::Rope::RopePhysics
      
      def initialize(num_links = 10)
        super()
        @links = [ ]
        0.upto(num_links-1) do |i|
          link = Link.new
          if i > 0
            link.siblings << links[i-1]
            links[i-1].siblings << link
          end
          links << link
        end
      end
      
      def position
        #average position of all links
        pos = Math::Vector.new
        links.each { |l| pos += l.position }
        pos /= links.length
        pos
      end
      
      def position=(p)
        incr = p - self.position
        links.each { |l| l.position += incr }
      end
      
      def render
        links.each do |link|
          glColor4f(1,1,1,1)
          glDisable(GL_TEXTURE_2D)
          glTranslatef(link.position.x, link.position.y, link.position.z)
          glBegin(GL_QUADS)
            glVertex3f(-0.25,-0.25,0)
            glVertex3f(-0.25, 0.25,0)
            glVertex3f( 0.25, 0.25,0)
            glVertex3f( 0.25,-0.25,0)
          glEnd
          glTranslatef(-link.position.x,-link.position.y,-link.position.z)
          glEnable(GL_TEXTURE_2D)
        end
      end
    end
  end
end