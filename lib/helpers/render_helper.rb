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
  
  def ortho(width, height, &block)
    __ortho(width, height, &block)
  end
end
