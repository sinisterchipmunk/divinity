# Defines some helpers to easily add components to a container
module Helpers::ContainerHelper
  def panel(constraints, &block)
    p = Interface::Containers::Panel.new(&block)
    self.add(p, constraints)
  end
end