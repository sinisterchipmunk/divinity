require 'dependencies'

include Gl

class GS
  include Physics::Gravity::GravitySource
  def position; Math::Vector.new(0,0,0); end
  def mass; 1000; end
end

def init_scene
  $scene = World::Scene.new
  $scene.gravitational_field.sources << GS.new
  $scene.objects << World::Objects::Rope.new
  $scene.objects[0].position = Math::Vector.new(1,1,1)
end

def init_gui
  #GUI testing
  $manager = Interface::Managers::FrameManager.new
  $manager.register_keyboard_shortcut(:keys   => [ SDL::Key::ESCAPE ],
                                     :target => self,
                                     :method => 'shutdown',
                                     :args   => [ ])
end

def init
  SDL.init(SDL::INIT_VIDEO)
  SDL.setGLAttr(SDL::GL_DOUBLEBUFFER,1)
  SDL.setVideoMode(512,512,32,SDL::OPENGL)
  Gl.glEnable(GL_BLEND)
  Gl.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  init_gui
  init_scene
  true
end

def render
    Gl.glClear( Gl::GL_COLOR_BUFFER_BIT | Gl::GL_DEPTH_BUFFER_BIT )
    Gl.glLoadIdentity()
    $manager.update(nil)
    $manager.render
    $scene.update
    $scene.render
end

def shutdown
  exit
end

def main_loop
  while true
    while event = SDL::Event2.poll
      case event
        when SDL::Event::Quit then exit
        when SDL::Event::MouseButtonDown, SDL::Event::MouseButtonUp, SDL::Event::MouseMotion then $manager.process_mouse_event(event)
        when SDL::Event::KeyDown, SDL::Event::KeyUp then $manager.process_key_event(event)
      end
    end
  
    render
    SDL.GLSwapBuffers()
    sleep 0.01 # to avoid consuming all CPU power
  end
end


init
main_loop
shutdown