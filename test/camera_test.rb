Dir.chdir '..'
require 'divinity_engine'
include Helpers::RenderHelper

=begin

This file constitutes my unit test of the Camera class. There should be 3 gray quads, one placed 5 units away
along each of the up, view and right vectors. These quads do not move once the demo starts, and are there to demonstrate
translation along those vectors (to prove they are accurate). If accurate, there should be one above, one to the right,
and one in front of the camera.

Use WSAD for move forward, move back, strafe left and strafe right, respectively.

Use Q to translate to an incrementing position in worldspace. This position starts at 1,1,1 and increments to 2,2,2;
3,3,3; 4,4,4; and so on. This should have the effect of moving you up, back and away from the quads.

Use E to translate to 1,1,1 in the camera's local space. This should have the effect of moving you one unit along each
of the view, up and right vectors, respectively. In worldspace, this would translate to one unit to the right; one
unit up; and one unit toward the quads.

Use the arrow keys to rotate the camera up, rotate the camera down, rotate the camera left, and rotate the camera right.

Use the Z and X keys to rotate the camera counter-clockwise and clockwise, respectively.

Press Y to lock the Y axis, and U to lock the up vector; press again to unlock.

=end

options = YAML::load(File.read("data/config.yml")) rescue {
        :width => 800,
        :height => 600,
        :fullscreen => true
}

afps = 0.0
frames = 0
ch = 0.0
t = 0
last_tick = 0
divinity = DivinityEngine.new(options)
scene = World::Scenes::HeightMap.new(divinity, "data/height_maps/test.bmp")

move_speed = 0
strafe_speed = 0
x_extent = y_extent = z_extent = 0
speed = 10 # units per second

divinity.on :key_pressed do |evt|
  case evt.sym
    when SDL::Key::W then move_speed += speed
    when SDL::Key::S then move_speed -= speed
    when SDL::Key::A then strafe_speed -= speed
    when SDL::Key::D then strafe_speed += speed
    when SDL::Key::UP then y_extent += speed
    when SDL::Key::DOWN then y_extent -= speed
    when SDL::Key::LEFT then x_extent -= speed
    when SDL::Key::RIGHT then x_extent += speed
    when SDL::Key::Z then z_extent -= speed
    when SDL::Key::X then z_extent += speed
  end
end

divinity.on :key_released do |evt|
  @q ||= 0
  @q += 1
  case evt.sym
    when SDL::Key::W then move_speed -= speed
    when SDL::Key::S then move_speed += speed
    when SDL::Key::A then strafe_speed += speed
    when SDL::Key::D then strafe_speed -= speed
    when SDL::Key::UP then y_extent -= speed
    when SDL::Key::DOWN then y_extent += speed
    when SDL::Key::LEFT then x_extent += speed
    when SDL::Key::RIGHT then x_extent -= speed
    when SDL::Key::Q then divinity.translate_to! @q, @q, @q
    when SDL::Key::E then divinity.translate! 1, 1, 1
    when SDL::Key::Y then divinity.lock_y_axis! !divinity.lock_y_axis?
    when SDL::Key::U then divinity.lock_up_vector! !divinity.lock_up_vector?
    when SDL::Key::Z then z_extent += speed
    when SDL::Key::X then z_extent -= speed
  end
end

# we buffer these because we want to make sure they do not move once demo starts
view = divinity.camera.view.dup
up = divinity.camera.up.dup
right = divinity.camera.right.dup

divinity.during_render do
  glColor4f 1, 1, 1, 1
  scene.render

  divinity.look!
  push_matrix do
    glTranslatef *(view*5).to_a # put one in front of the user
    render_quad
  end
  
  push_matrix do
    glTranslatef *(right*5).to_a # put one in front of the user
    render_quad
  end

  push_matrix do
    glTranslatef *(up*5).to_a # put one in front of the user
    render_quad
  end
end

def render_quad
  glDisable GL_TEXTURE_2D
  glBegin GL_QUADS
  glVertex3f -1, -1, 0
  glVertex3f -1,  1, 0
  glVertex3f  1,  1, 0
  glVertex3f  1, -1, 0
  glEnd
  glEnable GL_TEXTURE_2D
end

divinity.after_render do
  glColor4f 1, 1, 1, 1
  divinity.write(:right, :bottom, "AVG FPS: #{afps.to_i}")
  # this logic usually goes in the during_update block, but during_update only fires if the game is unpaused --
  # since the game is paused at the menu screens, it would never fire on them.
  # convert delta to seconds (it's in milliseconds atm)
  delta = ((divinity.ticks - last_tick) / 1000.0)
  last_tick = divinity.ticks
  if delta > 0 # to prevent divide-by-zero
    frames += 1.0 / delta # one frame per delta = 1/delta
    ch += 1               # one pass
    t += delta            # total change in time over ch passes
    if t >= 0.5           # update avg framerate every half-second
      afps = frames / ch  # average of frames-per-delta over the last ch passes
      ch, t, frames = 0, 0, 0
    end
  end
end

# IMPORTANT: When multithreading is implemented, #during_update will NO LONGER be a reliable
# way to count frames! This logic will need to be moved to #during_render to verify that it is
# running on the same thread as the frames themselves are.
divinity.during_update do |delta|
  delta /= 1000.0
  raise "move_speed is nil" if move_speed.nil?
  raise "strafe speed is nil" if strafe_speed.nil?
  raise "y_extent is nil" if y_extent.nil?
  raise "x_extent is nil" if x_extent.nil?
  
  divinity.move! move_speed * delta if move_speed != 0
  divinity.strafe! strafe_speed * delta if strafe_speed != 0
  divinity.rotate_view! y_extent * delta / 2, x_extent * delta / 2, z_extent * delta / 4
  
  scene.update delta unless divinity.paused?
end

divinity.after_shutdown do |divinity|
  File.open("data/config.yml", "w") { |f| f.print divinity.options.to_yaml }
end

divinity.go!
