class Devices::Keyboard < Devices::InputDevice
  extend Devices::Keyboard::Modifiers

  # TODO: key should have a Divinity wrapper around it; as is, it expects its SDL counterpart.
  def pressed?(key) SDL::Key.press?(key) end
  # TODO: key should have a Divinity wrapper around it; as is, it expects its SDL counterpart.
  def key_name(key) SDL::Key.get_key_name(key) end

  def update() SDL::Key.scan end
  def mod_state() SDL::Key.mod_state end
  def modifiers() self.class.array_of_modifiers(mod_state) end
  def enable_key_repeat!(delay = 100, interval = 100) SDL::Key.enable_key_repeat(delay, interval) end
  def disable_key_repeat!() SDL::Key.disable_key_repeat end
  def key_repeat=(a) a ? enable_key_repeat!(a, a) : disable_key_repeat! end

  alias scan update

  def respond_to_event?(event)
    event.device_type == :keyboard
  end

  def process_event(event)

  end

  private
end
