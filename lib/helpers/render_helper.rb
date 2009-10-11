module Helpers::RenderHelper
  include Gl
  include Glu

  def push_matrix
    glPushMatrix
    yield
    glPopMatrix
  end

  def ortho(width, height)
    glDisable(GL_DEPTH_TEST)
    glMatrixMode(GL_PROJECTION)
    glPushMatrix()
      glLoadIdentity()
      #We swap Y and HEIGHT here because most GUI development
      #works top-down, UNLIKE OpenGL. This reverses it.
      #                |--Y--|, |height|
      glOrtho(0, width, height,  0,       -1, 1)
      glMatrixMode(GL_MODELVIEW)
      glEnable(GL_SCISSOR_TEST)
      clip = Gl.glGetIntegerv(GL_SCISSOR_BOX)
      glPushMatrix()
        glLoadIdentity()
        yield
        glMatrixMode(GL_PROJECTION)
      glPopMatrix()
      glScissor(clip[0], clip[1], clip[2], clip[3])
      glMatrixMode(GL_MODELVIEW)
    glPopMatrix()
    glEnable(GL_DEPTH_TEST)
  end
end
