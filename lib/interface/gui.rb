module Interface
  module GUI
    @@focused = nil
    attr_accessor :visible, :enabled, :mouse_listeners, :key_listeners
    attr_reader :background, :parent
      
    def initialize
      @visible = true
      @enabled = true
      @background = nil
      @parent = nil
      @mouse_listeners = [ ]
      @key_listeners = [ ]
    end
    
    def GUI.focus(); @@focused; end
    def GUI.focus=(f); @@focused = f; end
    
    def screen_bounds; b = self.bounds; if parent then p = parent.screen_bounds; b.x += p.x; b.y += p.y; end; b; end
    def visible?() visible; end
    def enabled?() enabled; end
    def background=(b); @background = b; self.invalidate; end
    def root(); parent.nil? ? self : parent.root; end
    def focused(); @@focused == self; end
    def contains?(point); raise "GUI::contains? must be overridden"; end
    def bounds(); raise "GUI::bounds must be overridden"; end
    def update(time); raise "GUI::update must be overridden"; end
    def render(); raise "GUI::render must be overridden"; end
    
    #For each of the listener methods below, pass the evt object to the respective method for each
    #registered mouse listener.
    [ :released, :entered, :exited, :dragged, :moved, :pressed ].each do |method|
      define_method(
        "fire_mouse_#{method.to_s}", lambda do |evt|
          @mouse_listeners.each do |listener|
            listener.send("mouse_#{method.to_s}", evt)
          end
        end
                   )
    end
    
    #Ditto for keyboard.
    [ :pressed, :released, :typed ].each do |method|
      define_method(
        "fire_key_#{method.to_s}", lambda do |evt|
          @key_listeners.each do |listener|
            listener.send("key_#{method.to_s}", evt)
          end
        end
                   )
    end
    
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
    
    protected
    def parent=(p)
      @parent = p
      @frame = p.frame
      invalidate
    end
  end
end

