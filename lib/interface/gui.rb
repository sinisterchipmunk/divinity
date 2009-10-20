module Interface
  module Gui
    @@focused = nil
    attr_accessor :visible, :enabled
    attr_reader :background, :parent, :valid
      
    def initialize
      @visible = true
      @enabled = true
      @background = nil
      @parent = nil
    end

    def validate
      @valid = true
      @screen_bounds = nil# we buffer this so that we're not duping self.bounds every frame
      @screen_insets = nil 
    end

    def invalidate
      @valid = false
    end

    def valid?
      @valid
    end

    def Gui.focus(); @@focused; end
    def Gui.focus=(f); @@focused = f; end
    
    def screen_bounds
      if @screen_bounds.nil?
        @screen_bounds = self.bounds.dup
        if parent
          p = parent.screen_insets
          @screen_bounds.x += p.x
          @screen_bounds.y += p.y
        end
      end
      @screen_bounds
    end

    def screen_insets
      if @screen_insets.nil?
        @screen_insets = self.screen_bounds
        p = self.insets
        @screen_insets.x, @screen_insets.y, @screen_insets.width, @screen_insets.height =
                @screen_insets.x+p.x, @screen_insets.y+p.y, p.width, p.height
      end
      @screen_insets
    end

    def visible?() visible; end
    def enabled?() enabled; end
    def background=(b); @background = b; self.invalidate; end
    def root(); parent.nil? ? self : parent.root; end
    def focused(); @@focused == self; end
    def contains?(point); raise "Gui::contains? must be overridden"; end
    def bounds(); raise "Gui::bounds must be overridden"; end
    def update(time); raise "Gui::update must be overridden"; end
    def render(); raise "Gui::render must be overridden"; end
    
    def shortcut_activated
      ;
    end
    
    def frame
      return self if self.kind_of? Containers::Frame
      @frame
    end

    def frame_manager
      frame ? frame.frame_manager : nil
    end
    
    def parent=(p)
      @parent = p
      @frame = p.frame if p
      invalidate
    end
  end
end

