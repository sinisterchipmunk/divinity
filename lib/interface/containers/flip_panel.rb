class Interface::Containers::FlipPanel < Interface::Containers::Panel
  include Helpers::AttributeHelper

  attr_reader :components, :selected_index

  alias _add add
  alias _remove remove
  
  def initialize(&block)#object, method, &block)
    super(Interface::Layouts::BorderLayout.new)

    @previous_button = Interface::Components::ImageButton.new("data/ui/arrow_left.png")
    @next_button     = Interface::Components::ImageButton.new("data/ui/arrow_right.png")

    @previous_button.edge = false
    @next_button.edge = false
    
    @button_pane = Interface::Containers::Panel.new(Interface::Layouts::FlowLayout.new(:normal, :center))
    @button_pane.add @previous_button, [0,0]
    @button_pane.add @next_button, [1,0]

    @previous_button.on :action_performed do self.selected_index -= 1 end
    @next_button.on :action_performed do self.selected_index += 1 end

    @selected_index = 0
    @components = []

    _add @button_pane, :south

    yield_with_or_without_scope &block if block_given?
  end

  def selected_component
    if components[selected_index]
     # @object.components[selected_index][1]
      components[selected_index]#[0]
    else
      nil
    end
  end

  def add(comp, value)
    @components << comp #[ comp, value ]
    # verifies that whatever the selected index is, it is actually added (because it might not have existed
    # a moment ago)
    self.selected_component = selected_index
  end

  def remove(comp)
    @components.delete comp#@components.select { |i| i.comp == comp }.first
    _remove comp
    self.selected_index = self.selected_index
  end

  def selected_index=(index)
    self.selected_component = index
  end

  def selected_component=(index)
    if components.length > 0
      index %= -components.length if index < 0
      index %= components.length
    else
      index = 0
    end
    _remove selected_component if selected_component
    @selected_index = index
    _add selected_component, :center if selected_component
  end
end
