require File.join(File.dirname(__FILE__), 'dependencies')

# If the cursor is hidden (SDL.showCursor(0)) and the input is grabbed (SDL::WM.grabInput(SDL_GRAB_ON)),
# then the mouse will give relative motion events even when the cursor reaches
# the edge fo the screen.
# TODO: Provide an API for this in the DivinityEngine without forcing the user to interface directly to SDL.
class DivinityEngine
  include Gl
  include Engine::ContentLoader
#  extend Engine::ContentLoader
  include Engine::Delegation
  include Engine::DefaultRenderBlock
  include Engine::DefaultUpdateBlock
#  include Engine::Content
  include Engine::DefaultGui
  include Helpers::EventListeningHelper

  attr_reader :frame_manager, :state, :ticks, :interval, :options, :camera

  def initialize(*args, &blk)
    @blocks = {}
    @state = :waiting
    @camera = OpenGl::Camera.new

    during_init do
      @frame_manager = Interface::Managers::FrameManager.new
      @frame_manager.register_keyboard_shortcut(:keys   => [ SDL::Key::LALT, SDL::Key::F4 ],
                                                :target => self,
                                                :method => 'stop!',
                                                :args   => [ ])
      @frame_manager.should_update_viewport = false
    end

    @options = HashWithIndifferentAccess.new(args.extract_options!.reverse_merge(default_options))
    load_content!

    add_default_render_block
    add_default_update_block

    during_render &blk if block_given?
  end

  [ :width, :height, :color_depth, :fullscreen, :clear_on_render ].each do |i|
    eval "def #{i}; options[#{i.inspect}]; end", binding, __FILE__, __LINE__
  end

  def options=(o)
    @options.merge! o
#    init
  end

  def waiting?; @state == :waiting; end
  def running?; @state == :running; end
  def starting?; @state == :starting; end
  def paused?; @state == :paused; end
  def stopping?; @state == :stopping; end

  def go!
    if @state == :waiting
      init
    else
      @state = :starting
    end
    main_loop unless @main_loop_running
  end

  alias unpause! go!
  alias resume!  go!

  def pause!
    @state = :paused
  end

  def stop!
    @state = :stopping
  end

  def self.block_types(*types)
    types.each { |t| eval "def #{t}(&blk); add_game_block(#{t.inspect}, &blk); end", binding, __FILE__, __LINE__ }
  end

  block_types :before_init,     :during_init,   :after_init
  block_types :before_update,   :during_update, :after_update
  block_types :before_render,   :during_render, :after_render
  block_types :before_shutdown, :during_shutdown, :after_shutdown

  alias before_initialize before_init
  alias during_initialize during_init
  alias after_initialize  after_init

  private
    class EngineStopped; end

    def main_loop
      @main_loop_running = true
      # FIXME: Hitting a lot of issues with deadlock right now. I'm currently blaming ActiveSupport, but it could be
      # a synchronization issue within the engine. In the ideal world, we'd have the #update method firing on one
      # thread, and #render firing on the other. In a *perfect* world, we'd have different during_update blocks firing
      # on their own threads, with #render firing on a single thread.
#      Thread.new do
#        while @state != :stopping
#          ## Remove the following lines from the render thread when threads work again
#          @state = :running unless @state == :paused
#          update   
#        end
#      end

      while @state != :stopping
        @state = :running unless @state == :paused
        update
        render
        SDL.GLSwapBuffers()
      end

      @main_loop_running = false
      shutdown
    rescue EngineStopped
    ensure
      @state = :waiting
    end

    def render
      call_blocks :before_render, :during_render
      frame_manager.render
      call_blocks :after_render
    end

    def update
      @last_ticks ||= 0
      @ticks = SDL.getTicks
      @interval = @ticks - @last_ticks
      @last_ticks = @ticks

      call_blocks :before_update, :args => [ @interval, self ]
      call_blocks :during_update, :after_update, :args => [ @interval, self ] unless @state == :paused
    end

    def init_video_mode
      Textures::Font.invalidate!
      err("set video mode") unless (@sdl_screen = SDL.setVideoMode(options[:width], options[:height], options[:color_depth],
                                                                   sdl_video_mode_flags))
      glViewport(0, 0, options[:width], options[:height])
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity
      gluPerspective(90, width.to_f/height.to_f, 0.01, 150)
      glMatrixMode GL_MODELVIEW
      glLoadIdentity
      glEnable(GL_TEXTURE_2D)
      glEnable(GL_BLEND)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
      call_blocks :during_init
      init_default_gui
      call_blocks :after_init
    end
  
    def init
      @state = :initializing

      call_blocks :before_init
      SDL.init(SDL::INIT_VIDEO) and err("initialize SDL")
      SDL.setGLAttr(SDL::GL_DOUBLEBUFFER,1) and err("enable double-buffering")
      SDL.setGLAttr(SDL::GL_DEPTH_SIZE, 16) and err("set depth buffer size")
      SDL.setGLAttr(SDL::GL_RED_SIZE, 8) and err("set red bit depth")
      SDL.setGLAttr(SDL::GL_GREEN_SIZE, 8) and err("set green bit depth")
      SDL.setGLAttr(SDL::GL_BLUE_SIZE, 8) and err("set blue bit depth")
      SDL.setGLAttr(SDL::GL_ALPHA_SIZE, 8) and err("set alpha bit depth")
      SDL::Event.enable_unicode
      init_video_mode
    end

    def shutdown
      call_blocks :before_shutdown
      err "shut down SDL" if SDL.quit
      call_blocks :during_shutdown, :after_shutdown
    end

    def sdl_video_mode_flags
      flags = SDL::OPENGL
      flags |= SDL::FULLSCREEN if options[:fullscreen]

      flags
    end

    def call_blocks(*types)
      options = types.extract_options!
      types.each do |type|
        @blocks[type].each do |blk|
          if options.key? :args and blk.arity > 0
            if options[:args].kind_of? Array then blk.call(*(options[:args][0...(blk.arity)]))
            else blk.call(options[:args])
            end
          elsif blk.arity > 0
            blk.call(self)
          else
            blk.call
          end
        end if @blocks[type]
      end
    end

    def add_game_block(type, &blk)
      raise "Expected to evaluate a block #{type.to_s.humanize}" unless block_given?
      @blocks[type] ||= []
      @blocks[type] << blk
    end

    def err(action = nil)
      raise "Unknown Error!" if action.nil?
      raise "Error while attempting to #{action}"
    end
  
    def default_options
    {
      :width => 640, :height => 480, :color_depth => 32, :fullscreen => false,
      :clear_on_render => GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
    }
    end
end
