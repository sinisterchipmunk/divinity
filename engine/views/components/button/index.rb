## Concept

# Views are instance_eval'ed by an instance of Engine::View::Base, which contains all the helpers and whatnot necessary
# for rendering a given view.
#
# Instance variables are copied from the controller, and methods are copied from any helpers.
#

# note that theme can be called multiple times during the render, so that the textures can be swapped... ie use the
# primary background with the secondary foreground. Switching between themes for, as an example, using different fonts
# is greatly preferred to using a font or color directly, because the latter reduces the flexibility of a given
# theme.

# Best practice is to allow the user to configure all options via theme. That means we won't be specifying
# color or brightness, for example, if the button is pressed; instead, we'll switch to another theme set
# (such as :inset or :outset). This should actually be done in the controller, not the view.
if button.state == :pressed then theme :inset
else theme :outset
end


paint_background
paint_border

# text is centered vertically and horizontally by default. Other usages include:
#   text [label], [:west, :left, :east, :right], [:north, :top, :south, :bottom]
#   text [label], x_in_pixels, y_in_pixels_from_top_of_component
#
text button.caption
