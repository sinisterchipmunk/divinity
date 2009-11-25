module Devices::Keyboard::Modifiers
  MODIFIERS = { :none => SDL::Key::MOD_NONE,
                :lshift => SDL::Key::MOD_LSHIFT, :rshift => SDL::Key::MOD_RSHIFT,
                :lctrl  => SDL::Key::MOD_LCTRL,  :rctrl  => SDL::Key::MOD_RCTRL,
                :lalt   => SDL::Key::MOD_LALT,   :ralt   => SDL::Key::MOD_RALT,
                :lmeta  => SDL::Key::MOD_LMETA,  :rmeta  => SDL::Key::MOD_RMETA,
                :num_lock  => SDL::Key::MOD_NUM,
                :caps_lock => SDL::Key::MOD_CAPS,
                :mode      => SDL::Key::MOD_MODE,
                :reserved  => SDL::Key::MOD_RESERVED,
                :ctrl      => SDL::Key::MOD_CTRL,
                :shift     => SDL::Key::MOD_SHIFT,
                :alt       => SDL::Key::MOD_ALT,
                :meta      => SDL::Key::MOD_META,
              }
  
  def array_of_modifiers(mod)
    r = []
    MODIFIERS.each do |sym, val|
      r << sym if mod & val > 0
    end
    r
  end
end