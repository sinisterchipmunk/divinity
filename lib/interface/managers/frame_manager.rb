class Interface::Managers::FrameManager
  include Helpers::RenderHelper
  attr_reader :viewport
  attr_accessor :theme
  delegate :x, :y, :width, :height, :size, :bounds, :to => :viewport

  def initialize
    @frames = [ ]
    @shortcuts = [ ]
    @location_manager = FrameLocationManager.new
    @viewport = Screen::Viewport.new
    @location_manager.viewport = @viewport
    @last_mouse_event_target = nil
    @mouse_button_down = false
    @last_key_event = nil
    @last_mouse_click_event = nil
    @theme = Interface::Themes::DefaultTheme.new
  end

  def should_update_viewport?
    @should_update_viewport
  end

  def should_update_viewport=(a)
    @should_update_viewport = a
  end

  #takes a hash { keys => [ SDL::Key::* ],
  #               target => Object,
  #               method => 'method_name' or nil,
  #               args => [ args ] }
  def register_keyboard_shortcut(shortcut)
    @shortcuts <<= shortcut
  end

  def add(*frames)
    frames.each do |frame|
      @frames.delete frame #In case it's already been registered.
      @frames <<= frame
      frame.frame_manager = self
      frame.location ||= @location_manager.request(frame.size)
      frame.invalidate
    end
  end

  def remove(*frames)
    frames.each do |frame|
      frame.frame_manager = nil
      @frames.delete frame
    end
  end

  def bring_to_front(comp)
    if comp.frame
      @frames.delete comp.frame
      @frames.insert 0, comp.frame
    end
  end

  def send_to_back(comp)
    if comp.frame
      @frames.delete comp.frame
      @frames <<= comp.frame
    end
  end

  def update(time)
    @viewport.update if should_update_viewport?
    @frames.each { |frame| next unless frame.enabled?; frame.validate if not frame.valid; frame.update(time) }
  end

  def render
    ortho(@viewport.width, @viewport.height) do
      #Last in array is first to display (it's on bottom)
      @frames.reverse.each do |frame|
        next unless frame.visible?
        #Frame used to be a non-component (derived directly from GUI).
        #After Frame became a component, the translating was done twice, once here
        #and once in Component. Obviously, this is a Bad Thing. Hence the comments.
        b = frame.screen_bounds
        Gl.glPushAttrib(GL_COLOR_BUFFER_BIT | GL_LIST_BIT | GL_TRANSFORM_BIT | GL_SCISSOR_BIT)
        Gl.glScissor(b.x+1, @viewport.height - b.y - b.height, b.width+1, b.height+1)
        #glTranslated( frame.bounds.x,  frame.bounds.y, 0)
        frame.render
        #glTranslated(-frame.bounds.x, -frame.bounds.y, 0)
        Gl.glPopAttrib()
      end
    end
  end

  def getGUIAt(pos)
    @frames.each do |ch|
      if ch.contains?(pos)
        ret = nil
        ret = ch.get_child_at(pos) if ch.respond_to? :get_child_at
        ret = ch if ret.nil?
        return ret
      end
    end
    return nil
  end

  def process_key_event(evt)
    if @shortcuts.length > 0 and evt.kind_of? SDL::Event::KeyDown
      SDL::Key.scan
      done = false
      @shortcuts.each do |shortcut|
        keys   = shortcut[:keys]
        target = shortcut[:target]
        method = shortcut[:method] or "shortcut_activated"
        args   = shortcut[:args] or [ ]
        found = true
        keys.each do |key|
          found = false unless SDL::Key.press?(key)
        end
        next if not found

        #shortcut is being pressed
        unless target.respond_to? :enabled? and not target.enabled?
          if not args.nil? and args.length > 0
            target.send(method, args)
            return
          else
            target.send(method)
          end
        end
      end
      return if done
    end
    if Interface::GUI.focus
      Interface::GUI.focus.fire_key_pressed(evt)  if evt.kind_of? SDL::Event::KeyDown and Interface::GUI.focus.enabled?
      Interface::GUI.focus.fire_key_released(evt) if evt.kind_of? SDL::Event::KeyUp  and Interface::GUI.focus.enabled?
    end
    @last_key_event = evt
  end

  def process_mouse_event(evt)
    target = nil
    if evt.kind_of? SDL::Event::MouseMotion
      pos = Geometry::Point.new(evt.x, evt.y)
      target = getGUIAt(pos)
      if target != @last_mouse_event_target
        @last_mouse_event_target.fire_mouse_exited(evt) if @last_mouse_event_target and @last_mouse_event_target.enabled?
        target.fire_mouse_entered(evt) if target and target.enabled?
      end
      if Interface::GUI.focus
        if @mouse_button_down
          btn = @last_mouse_click_event.button
          #give the listener an idea of which button is being dragged
          def evt.button; btn; end
          Interface::GUI.focus.fire_mouse_dragged(evt) if Interface::GUI.focus.enabled?
        end
      end

      target.fire_mouse_moved(evt) if target and not @mouse_button_down and target.enabled?
      @last_mouse_event_target = target
    elsif evt.kind_of? SDL::Event::MouseButtonDown
      pos = Geometry::Point.new(evt.x, evt.y)
      target = getGUIAt(pos)
      Interface::GUI.focus = target
      if target and target.enabled?
        target.fire_mouse_pressed(evt)
        bring_to_front(target)
      end
      @last_mouse_event_target = target
      @last_mouse_click_event = evt
      @mouse_button_down = true
    elsif evt.kind_of? SDL::Event::MouseButtonUp
      Interface::GUI.focus.fire_mouse_released(evt) if Interface::GUI.focus and Interface::GUI.focus.enabled?
      @mouse_button_down = false
      @last_mouse_click_event = evt
    end
  end
end
