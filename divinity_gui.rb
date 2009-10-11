require 'dependencies'

include Gl
include Geometry

def init_gui
  #GUI testing
  container = Interface::Containers::Container.new(Interface::Layouts::FlowLayout.new)
  frame = Interface::Containers::Frame.new
  frame.add(container, "Center")
  frame.pack
  frame.size = Dimension.new(200, 200)
  $manager = Interface::Managers::FrameManager.new
  $manager.add(frame)
  $manager.register_keyboard_shortcut(:keys   => [ SDL::Key::ESCAPE ],
                                     :target => self,
                                     :method => 'shutdown',
                                     :args   => [ ])
end

def init
  SDL.init(SDL::INIT_VIDEO)
  SDL.setGLAttr(SDL::GL_DOUBLEBUFFER,1)
  SDL.setVideoMode(512,512,32,SDL::OPENGL)# | SDL::FULLSCREEN)
  Gl.glEnable(GL_BLEND)
  Gl.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  init_gui
  true
end

def render
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glLoadIdentity()
    $manager.update(nil)
    $manager.render
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
    #sleep 0.01 # to avoid consuming all CPU power
  end
end


init
main_loop
shutdown