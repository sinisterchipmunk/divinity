interface :options do
  layout :grid, 3, 12
  options = engine.options.dup
  toggle_button [1,2], options, "[:fullscreen]", :caption => "Full Screen", :delimeter => ""

  panel [1,9] do
    layout :grid, 2, 1
    button [0,0], :cancel, :action => :main_menu
    button [1,0], :apply_now, :action => (proc do
      engine.options = options
      assume_interface :force_restart
    end)
  end
end
