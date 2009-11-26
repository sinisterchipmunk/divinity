class Engine::Controller::KeyboardProxy < Engine::Controller::InputDeviceProxy
  # device methods
  delegate :pressed?, :key_name, :update, :scan, :mod_state, :modifiers, :enable_key_repeat!, :disable_key_repeat!,
           :key_repeat=, :respond_to_event?, :process_event,
           :to => :device
end
