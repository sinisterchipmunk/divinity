module Interface::Components::Component::RenderMethods
  def render
    b = bounds
    return unless visible? and b.height > 0 and b.width > 0
    push_matrix do
      push_attrib do
        glColor4fv [1,1,1,1]
        glTranslated( b.x,  b.y, 0)
        scissor do
          if background_visible?
            paint_background
            paint_border
          end
        end
        glTranslated(insets.x, insets.y, 0)
        scissor insets do
          glColor4fv foreground_color
          paint
        end
      end
    end
  end

  def paint_border
#    push_attrib do
#      glDisable(GL_TEXTURE_2D)
#      glColor4fv(theme[:foreground_color] || [1,1,1,1])
#      glBegin(GL_LINE_STRIP)
#        glVertex2i(insets.x, insets.y)
#        glVertex2i(insets.x, insets.y+insets.height)
#        glVertex2i(insets.x+insets.width, insets.y+insets.height)
#        glVertex2i(insets.x+insets.width, insets.y)
#        glVertex2i(insets.x, insets.y)
#      glEnd
#    end
  end

  def paint_background
    background_texture.bind do
      glBegin(GL_QUADS)
        background_texture.coord2f(0, 0); glVertex2i(0, 0)
        background_texture.coord2f(0, 1); glVertex2i(0, bounds.height)
        background_texture.coord2f(1, 1); glVertex2i(bounds.width, bounds.height)
        background_texture.coord2f(1, 0); glVertex2i(bounds.width, 0)
      glEnd
    end
  end

  def paint(); end

  def update_background_texture
    @foreground_color = theme[:foreground_color] if theme[:foreground_color]
    unless @foreground_color.kind_of? Array and @foreground_color.length == 4 and
           @foreground_color.select { |i| not i.kind_of? Fixnum or i < 0 || i > 1 }.length == 0
      raise "Foreground color should be an array of four numbers between 0 and 1 (ie [1,1,1,1] for white)"
    end
    background_texture.set_options theme
    background_texture.set_option(:raise_size, 3)
    background_texture.set_option(:width,  self.bounds.width)
    background_texture.set_option(:height, self.bounds.height)
  end
end
