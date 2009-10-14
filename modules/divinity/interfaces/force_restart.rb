interface :force_restart do
  layout :grid, 3, 3
  panel [1,1] do
    layout :border

    label "You must restart the game in order to continue.", :constraints => :center
    button :exit, :constraints => :south, :action => (proc do
      engine.after_shutdown do exec "ruby divinity_test.rb" end
      engine.stop!
    end)
  end
end