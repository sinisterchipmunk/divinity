class Events::MouseEvents::MouseEvent < Events::InputEvent
  def device_type
    :mouse
  end

  # for compatibility across mouse events: returns false.
  def click?() false end
end
