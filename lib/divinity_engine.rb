require File.join(File.dirname(__FILE__), 'dependencies')

# If the cursor is hidden (SDL.showCursor(0)) and the input is grabbed (SDL::WM.grabInput(SDL_GRAB_ON)),
# then the mouse will give relative motion events even when the cursor reaches
# the edge fo the screen.
# TODO: Provide an API for this in the DivinityEngine without forcing the user to old directly to SDL.
#
# Note: Joystick support not yet implemented.
class DivinityEngine
  include Gl
  include Engine::ContentLoader
  include Engine::Controller::Routing
  include Engine::Delegation
  include Engine::DefaultRenderBlock
  include Engine::DefaultUpdateBlock
  include Helpers::EventListeningHelper

  attr_reader :state, :ticks, :interval, :options, :camera, :mouse, :keyboard, :logger
  attr_accessor :current_theme

  def blocks(type)
    @blocks[type] ||= []
  end
  private :blocks

  def initialize(*args, &blk)
    @options = HashWithIndifferentAccess.new(args.extract_options!.reverse_merge(default_options))
    @blocks = {}
    @state = :waiting
    @camera = OpenGl::Camera.new
    @mouse = Devices::Mouse.new(self)
    @keyboard = Devices::Keyboard.new(self)
    @logger = Divinity.engine_logger
    load_content!

    during_init do
      self.current_theme = themes(options[:theme])
    end

    add_default_render_block
    add_default_update_block

    during_render &blk if block_given?
    @initialized = true
  end

  def initialized?
    @initialized
  end

  [ :width, :height, :color_depth, :fullscreen, :clear_on_render ].each do |i|
    eval "def #{i}; options[#{i.inspect}]; end", binding, __FILE__, __LINE__
  end

  # True if options[:dry_run] has been set to true; determines whether the engine will be started in "dry run" mode.
  #
  # When in "dry run" mode, Divinity will run without user interaction. User input events will only be processed if the
  # window is active, but the window itself will be invisible. Fullscreen mode is forcefully disabled during a dry run.
  #
  # Log mode is set to DEBUG during a dry run.
  #
  # During a dry run, the engine should be programmatically stopped via #stop! in order to exit.
  #
  def dry_run?; options[:dry_run]; end

  def options=(o)
    @options.merge! o
#    init
  end

  def waiting?;  @state == :waiting;  end
  def running?;  @state == :running;  end
  def starting?; @state == :starting; end
  def paused?;   @state == :paused;   end
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

  block_types :before_init,       :during_init,       :after_init
  block_types :before_initialize, :during_initialize, :after_initialize
  block_types :before_update,     :during_update,     :after_update
  block_types :before_render,     :during_render,     :after_render
  block_types :before_shutdown,   :during_shutdown,   :after_shutdown

  alias before_initialize before_init
  alias during_initialize during_init
  alias after_initialize  after_init

  private
    class EngineStopped; end

    def main_loop
      @main_loop_running = true
      # FIXME: Hitting a lot of issues with deadlock right now. I'm currently blaming ActiveSupport, but it could be
      # a synchronization issue within the engine. In a better world, we'd have the #update method firing on one
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
      # TODO: we should probably render an old here.
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
      if dry_run?
        options[:width] = options[:height] = 1
        options[:noframe] = true
        options[:fullscreen] = false
      end
      Textures::Font.invalidate!
      err("set video mode") unless (@sdl_screen = SDL.setVideoMode(options[:width], options[:height],
                                                                   options[:color_depth], sdl_video_mode_flags))
      glViewport(0, 0, options[:width], options[:height])
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity
      gluPerspective(90, width.to_f/height.to_f, 0.01, 150)
      glMatrixMode GL_MODELVIEW
      glLoadIdentity
      glEnable(GL_TEXTURE_2D)
      glEnable(GL_BLEND)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
      call_blocks :during_init, :during_initialize
      #init_default_gui
      call_blocks :after_init, :after_initialize
    end
  
    def init
      @state = :initializing

      call_blocks :before_init, :before_initialize
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
      flags |= SDL::NOFRAME if options[:noframe]
      flags
    end

    def call_blocks(*types)
      options = types.extract_options!
      types.each do |type|
        blocks(type).each do |blk|
          if options.key? :args and blk.arity > 0
            if options[:args].kind_of? Array then blk.call(*(options[:args][0...(blk.arity)]))
            else blk.call(options[:args])
            end
          elsif blk.arity > 0
            blk.call(self)
          else
            blk.call
          end
        end
      end
    end

    def add_game_block(type, &blk)
      raise "Expected to evaluate a block #{type.to_s.humanize}" unless block_given?
      blocks(type) << blk
    end

    def err(action = nil)
      raise "Unknown Error!" if action.nil?
      raise "Error while attempting to #{action}"
    end
  
    def default_options
    {
      :width => 640, :height => 480, :color_depth => 32, :fullscreen => false,
      :clear_on_render => GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT,
      :theme => :default, :dry_run => ENV['DRY_RUN'] || false
    }
    end
end
