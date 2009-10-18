class Interface::Containers::Panel < Interface::Components::Component
  include Interface::Containers::Container

  def initialize(layout=Interface::Layouts::FlowLayout.new, &blk)
    super()
    self.layout = layout
    self.background_visible = false
  end
end
