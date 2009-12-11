require 'config/boot'

total_rotation = 0
distance = 10

engine = DivinityEngine.new(:width => 800, :height => 600, :fullscreen => false)

engine.during_render do
  # do some OpenGL rendering
  glDisable GL_TEXTURE_2D           # disable textures (we're not using them)
  glColor4f 1, 1, 1, 1              # set color to white (1 red, 1 green, 1 blue, 1 alpha [not transparent])
  engine.look!                      # apply the current camera transformations
  glTranslatef -5, 0, -5            # move forward and left 5 units
  colors = [[1,0,0,1],[0,1,0,1],[0,0,1,1]]
  3.times do |color|
    # draw a square and then move 5 units to the right; do this 3 times
    glColor4fv(colors[color])
    glBegin GL_QUADS
      glVertex3f -1, -1, 0 # top left
      glVertex3f -1,  1, 0 # bottom left
      glVertex3f  1,  1, 0 # bottom right
      glVertex3f  1, -1, 0 # top right
    glEnd
    glTranslatef(5,0,0)
  end
end

# Update some stuff between frames
engine.during_update do |delta|
  # Delta is the time differential in milliseconds between previous and current updates

  seconds = (delta / 1000.0)        # convert delta to seconds
  speed   = 2*Math::PI              # Rotate 2PI radians per second
  total_rotation += speed * seconds # update total rotation

  # find x and z to translate to (we won't move vertically this time)
  x, y, z = Math.cos(total_rotation) * distance, 0, Math.sin(total_rotation) * distance
  engine.translate_to! x, y, z

  # we want the camera to always be pointed at the squares
  engine.look_at! 0, 0, -5
end

engine.go! # start the engine
