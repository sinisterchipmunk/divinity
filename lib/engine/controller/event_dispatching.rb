module Engine::Controller::EventDispatching
  def dispatch_event(type, event)
    # only a few events could be potentially dispatched to something other than
    # the currently focused child.
    if type == :mouse_moved
      dispatch_event_to_component_at(type, event, event.x, event.y)
    elsif type == :mouse_pressed # If it's not the focused component, then it's about to be.
      c = find_component_at(event.x, event.y)
      focus!(c)
      dispatch_event_to_focused_component(type, event)
    else
      dispatch_event_to_focused_component(type, event)
    end
  end

  # Focuses the specified component, fires a focus event for both the previously and newly focused components,
  # and then returns the previously focused component. If the previous and current components are identical,
  # nothing happens and that component is returned. The actual assignment of the instance variable representing
  # the focused component happens after the focus_lost event has fired and before the focus_gained event has fired.
  def focus!(comp)
    prev = @focused
    unless prev == comp
      evt = Events::FocusEvent.new(prev, comp)
      prev.process_event(:focus_lost, evt) if prev
      @focused = comp
      comp.process_event(:focus_gained, evt)
    end
    prev
  end

  # Returns the component at the given x,y coordinates. If this component has a parent, then x,y are
  # expected to be in the parent's local space; if this is a root-level component, then x,y may be in
  # screen space (since root-level components take up the entire screen).
  #
  # If a subcomponent cannot be found, self is returned.
  def find_component_at(x, y)
    # need to find the child at this x/y position.
    # As we translate deeper into the component nest, we need to subtract the upper-left bounds of
    # each component from x,y in order to stay in each component's local space. If we are at the root
    # level, then our upleft bounds is 0,0 and it won't matter.
    x, y = translate(x, y)
    components.each { |comp| return comp.find_component_at(x, y) if comp.contains? x, y }
    self
  end

  # Dispatches the event to the component at the specified coordinates, and then returns that component.
  def dispatch_event_to_component_at(type, event, x, y)
    (c = find_component_at(x, y)).process_event(type, event)
    c
  end

  # Dispatches the event to the currently-focused component, and then returns that component.
  def dispatch_event_to_focused_component(type, event)
    @focused.process_event(type, event) if @focused
  end
end
