module Devices
  class Keyboard < Devices::InputDevice
    extend Modifiers

    # FIXME: Keyboard class needs a total reimplementation.


    
    # TODO: key should have a Divinity wrapper around it; as is, it expects its SDL counterpart.
    #def pressed?(key) SDL::Key.press?(key) end
    # TODO: key should have a Divinity wrapper around it; as is, it expects its SDL counterpart.
    #def key_name(key) SDL::Key.get_key_name(key) end

    def update() raise 'n/a' end#SDL::Key.scan end
    def mod_state() SDL.GetModState end
    def modifiers() self.class.array_of_modifiers(mod_state) end
    def enable_key_repeat!(delay = 100, interval = 100) SDL.EnableKeyRepeat(delay, interval) end
    def disable_key_repeat!() SDL.EnableKeyRepeat(0, 0) end #SDL::Key.disable_key_repeat end
    def key_repeat=(a) a ? enable_key_repeat!(a, a) : disable_key_repeat! end

    alias scan update

    def respond_to_event?(event)
      event.device_type == :keyboard
    end

    def process_event(event)

    end

    private
  end
end
