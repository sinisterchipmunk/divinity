# A panel basically just helps encapsulate the concept of one component holding another. It's a purely interpretive
# thing: you could just as easily have a Components::ComponentController in its place. That said, you can imagine how
# empty a Panel is going to be. We have an index action to provide a starting point, and it points to an empty view.
# It's utterly empty in here.
#
# Of course, it inherits the default themeset, so a user could customize some content into it pretty easily.
#
class Components::PanelController < Components::ComponentController
  def index
  end
end
