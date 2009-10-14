class Interface::Containers::ScrollPanel < Interface::Containers::Panel
  def initialize(*a, &b)
    super(Interface::Layouts::BorderLayout.new)

    @content = Interface::Containers::Panel.new(*a, &b)
    #@scroll  = ScrollBar.new

    add @content,   :center
    #add @scrollbar, :east
  end
end
