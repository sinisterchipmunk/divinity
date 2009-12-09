## Remove me, or do something smart with me. Either way, I don't belong here.

require 'divinity_engine'
include Math

total_rotation = 0
distance = 10

def draw_quad
  glBegin GL_QUADS
    glVertex3f -1, -1, 0
    glVertex3f -1,  1, 0
    glVertex3f  1,  1, 0
    glVertex3f  1, -1, 0
  glEnd
end

engine = DivinityEngine.new(:width => 800, :height => 600, :fullscreen => false)

engine.during_render do
  # do some OpenGL rendering
  glDisable GL_TEXTURE_2D                    # disable textures (we're not using them)
  glColor4f 1, 1, 1, 1                       # set color to white (1 red, 1 green, 1 blue, 1 alpha [not transparent])
  engine.look!                               # apply the current camera transformations
  glTranslatef -5, 0, -5                     # move forward and left 5 units
  3.times { draw_quad; glTranslatef(5,0,0) } # draw a square and then move 5 units to the right; do this 3 times
end

engine.during_update do |delta|
  # update some stuff, like 3D models, etc. Delta is the time differential between last update and this update,
  # in milliseconds.
  seconds = (delta / 1000.0) # convert delta to seconds
  speed   = 2*PI # Rotate 2PI radians per second
  total_rotation += speed * seconds # update total rotation
  # find x and z to translate to (we won't move vertically this time)
  x, y, z = cos(total_rotation) * distance, 0, sin(total_rotation) * distance
  engine.translate_to! x, y, z
  # we want the camera to always be pointed at the square
  engine.look_at! 0, 0, -5
end

engine.go! # start the engine
