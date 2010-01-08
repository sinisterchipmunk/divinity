module Devices::Keyboard::Modifiers
  MODIFIERS = { :none => SDL::KMOD_NONE,
                :lshift => SDL::KMOD_LSHIFT, :rshift => SDL::KMOD_RSHIFT,
                :lctrl  => SDL::KMOD_LCTRL,  :rctrl  => SDL::KMOD_RCTRL,
                :lalt   => SDL::KMOD_LALT,   :ralt   => SDL::KMOD_RALT,
                :lmeta  => SDL::KMOD_LMETA,  :rmeta  => SDL::KMOD_RMETA,
                :num_lock  => SDL::KMOD_NUM,
                :caps_lock => SDL::KMOD_CAPS,
                :mode      => SDL::KMOD_MODE,
                :reserved  => SDL::KMOD_RESERVED,
                #:ctrl      => SDL::KMOD_CTRL,
                #:shift     => SDL::KMOD_SHIFT,
                #:alt       => SDL::KMOD_ALT,
                #:meta      => SDL::KMOD_META,
              }

  def array_of_modifiers(mod)
    r = []
    MODIFIERS.each do |sym, val|
      r << sym if mod & val > 0
    end
    r
  end
end
