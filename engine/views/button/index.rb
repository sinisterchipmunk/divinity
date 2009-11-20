## Concept

# Views are instance_eval'ed by an instance of Engine::View::Base, which contains all the helpers and whatnot necessary
# for rendering a given view.
#
# Instance variables are copied from the controller, and methods are copied from any helpers.
#

# note that theme can be called multiple times during the render, so that the textures can be swapped... ie use the
# primary background with the secondary foreground.
theme :primary

if button.state == :pressed then background :brightness => 0.8
else background
end

# text is centered vertically and horizontally by default. Other usages include:
#   text [label], [:west, :left, :east, :right], [:north, :top, :south, :bottom]
#   text [label], x_in_pixels, y_in_pixels_from_top_of_component
#
text button.caption
