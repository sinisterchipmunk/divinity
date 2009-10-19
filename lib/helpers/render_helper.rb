module Helpers::RenderHelper
  include Gl
  include Glu

  def push_matrix
    glPushMatrix
    yield
    glPopMatrix
  end

  def push_attrib(attrib = GL_ALL_ATTRIB_BITS)
    glPushAttrib attrib
    yield
    glPopAttrib
  end

  def scissor(x, y, w, h)
    push_attrib GL_SCISSOR_BIT do
      glScissor(x, y, w, h)
      yield
    end
  end

  def wireframe
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    yield
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
  end
  
  def ortho(width, height)
    glDisable(GL_DEPTH_TEST)
    glMatrixMode(GL_PROJECTION)
    push_matrix do
      glLoadIdentity()
      #We swap Y and HEIGHT here because most GUI development
      #works top-down, UNLIKE OpenGL. This reverses it.
      #                |--Y--|, |height|
      glOrtho(0, width, height,  0,       -1, 1)
      glMatrixMode(GL_MODELVIEW)
      glEnable(GL_SCISSOR_TEST)
      push_matrix do
        glLoadIdentity()
        yield
        glMatrixMode(GL_PROJECTION)
      end
      glDisable GL_SCISSOR_TEST
      glMatrixMode(GL_MODELVIEW)
    end
    glEnable(GL_DEPTH_TEST)
  end
end
