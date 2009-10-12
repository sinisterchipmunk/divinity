require 'dependencies'

class DivinityEngine
  include Gl
  extend Engine::ContentLoader
  include Engine::Delegation
  include Engine::DefaultRenderBlock
  include Engine::DefaultUpdateBlock
  include Engine::Content
  include Engine::DefaultGUI

  attr_reader :frame_manager, :state, :ticks, :interval
  attr_accessor :clear_on_render, :width, :height, :color_depth, :fullscreen

  def initialize(*args, &blk)
    @blocks = {}
    @state = :waiting
    @frame_manager = Interface::Managers::FrameManager.new
    @frame_manager.register_keyboard_shortcut(:keys   => [ SDL::Key::LALT, SDL::Key::F4 ], :target => self, :method => 'stop!',
                                              :args   => [ ])
    @frame_manager.should_update_viewport = false

    options = args.extract_options!.reverse_merge(default_options)
    options.each { |key,value| self.send("#{key}=", value) }
    
    add_default_render_block
    add_default_update_block

    during_render &blk if block_given?
  end

  def go!
    init if @state == :waiting
    @state = :starting
    main_loop
  end

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

  private
    class EngineStopped; end

    def main_loop
      while @state != :stopping
        @state = :running unless @state == :paused
        update # TODO: Multithread this.
        render

        SDL.GLSwapBuffers()
        #sleep 0.01 # to avoid consuming all CPU power
      end
    rescue EngineStopped
    ensure
      @state = :waiting
    end

    def render
      call_blocks :before_render, :during_render, :after_render
    end

    def update
      @last_ticks ||= 0
      @ticks = SDL.getTicks
      @interval = @ticks - @last_ticks
      @last_ticks = @ticks

      call_blocks :before_update, :during_update, :after_update, :args => [ @interval, self ] unless @state == :paused
    end
  
    def init
      @state = :initializing

      call_blocks :before_init
      SDL.init(SDL::INIT_VIDEO) and err("initialize SDL")
      SDL.setGLAttr(SDL::GL_DOUBLEBUFFER,1) and err("enable double-buffering")
      SDL::Event.enable_unicode
      err("set video mode") unless (@sdl_screen = SDL.setVideoMode(width,height,color_depth,sdl_video_mode_flags))
      glEnable(GL_BLEND)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
      init_default_gui
      
      call_blocks :during_init, :after_init
    end

    def shutdown
      call_blocks :before_shutdown
      attempt "shut down SDL" do SDL.quit end
      call_blocks :during_shutdown, :after_shutdown
    end

    def sdl_video_mode_flags
      flags = SDL::OPENGL
      flags |= SDL::FULLSCREEN if fullscreen

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
