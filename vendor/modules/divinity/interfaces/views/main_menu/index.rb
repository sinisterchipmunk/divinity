# Button generates 'button_clicked' events. The "button" method below automatically registers the controller
# for this view to listen for that event. If it is "heard", and a button_clicked method exists in the controller (this
# must be user-defined), then that method will be called.
panel :center, :theme => :primary do
  layout :grid, 3, 12
  
  button [1,4], "Single Player"
  button [1,6], "Options"
  button [1,7], "Quit"
end
