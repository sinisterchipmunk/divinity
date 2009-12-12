module ApplicationHelper
  def gl_quad(size = 1)
    glBegin GL_QUADS
      glVertex3f -size, -size, 0          # top left
      glVertex3f -size,  size, 0          # bottom left
      glVertex3f  size,  size, 0          # bottom right
      glVertex3f  size, -size, 0          # top right
    glEnd
  end
end
