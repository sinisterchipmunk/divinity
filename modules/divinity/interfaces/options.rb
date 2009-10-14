interface :options do
  layout :grid, 3, 12
  options = engine.options.dup
  toggle_button options, "[:fullscreen]", "Full Screen", [1, 2], :delimeter => ""

  panel [1,9] do
    layout :grid, 2, 1
    button :cancel, :constraints => [0, 0], :action => :main_menu
    button :apply_now, :constraints => [1, 0], :action => (proc do
      engine.options = options
      assume_interface :force_restart
    end)
  end
end
