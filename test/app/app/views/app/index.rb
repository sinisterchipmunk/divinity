# do some OpenGL rendering
glDisable GL_TEXTURE_2D           # disable textures (we're not using them)
engine.look!                      # apply the current camera transformations
glTranslatef -5, 0, -5            # move forward and left 5 units
3.times do |color|
  # draw a square and then move 5 units to the right; do this 3 times
  glColor4fv(@colors[color])      # set the current color
  gl_quad                         # defined in helpers/application_helper.rb
  glTranslatef(5,0,0)
end

render :partial => 'framerate'
