class Devices::Mouse < Devices::InputDevice
  class State
    attr_reader :x, :y

    def initialize(x, y, left, middle, right)
      @x, @y, @left, @middle, @right = x, y, left, middle, right
    end

    def pressed?(which)
      case which
        when :any then @left || @middle || @right
        when :left then @left
        when :middle then @middle
        when :right then @right
        else raise "Don't recognize button: #{which.inspect} (expected one of [:left, :middle, :right])"
      end
    end
  end

  delegate :x, :y, :pressed?, :to => :state
  attr_reader :cursor

  def state() State.new(*SDL::Mouse.state) end
  def warp_to!(x, y) SDL::Mouse.warp(x, y) end
  def show!() SDL::Mouse.show end
  def hide!() SDL::Mouse.hide end
  
  def cursor=(cursor)
    @cursor = cursor
    if @cursor.replaces_sdl?
      hide!
    else
      show!
      SDL::Mouse.set_cursor(*@cursor.sdl_cursor_args)
    end
    @cursor
  end

  def respond_to_event?(event)
    event.device_type == :mouse
  end

  def process_event(event)
    case event
      when Events::MouseMoved
        type = event.dragged? ? :mouse_dragged : :mouse_moved
      when Events::MousePressed
        type = :mouse_pressed
      when Events::MouseReleased
        type = :mouse_released
    end

    engine.dispatch_event type, event

    process_clicking(type, event)
  end

  private
  def process_clicking(type, event)
    click_timeout = 200
    @last_press ||= {}
    @last_release ||= {}
    @click_count ||= {}

    case type
      when :mouse_pressed
        @last_press[event.button] = engine.ticks
        @click_count[event.button] = 0 if @last_press[event.button] - @last_release[event.button].to_i > click_timeout
      when :mouse_released
        cur_release = @last_release[event.button] = engine.ticks
        last_press = @last_press[event.button]

        if last_press && cur_release - last_press < click_timeout
          # it's a click
          @click_count[event.button] += 1
          event.send(:click_count=, @click_count[event.button])

          engine.fire_event :mouse_clicked, event unless engine.paused?
          engine.dispatch_event :mouse_clicked, event
        end
    end
  end
end
