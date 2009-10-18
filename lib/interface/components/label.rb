class Interface::Components::Label < Interface::Components::InputComponent
  theme_selection :text
  attr_accessor :color, :label

  def after_initialize(options)
    self.label = self.value
    on :value_changed do value_changed end
    set_options! options
    size # init size object
  end

  def value_changed
    @label = value.to_s
    @size = font.sizeof(@label.to_s)
    invalidate
  end

  def paint
    Font.select.put((insets.width - size.width) / 2, (insets.height / 2) - (size.height / 2), label)
  end

  def size
    @size ||= font.sizeof(@label.to_s)
  end

  def minimum_size; size_with_insets(size) end
  def maximum_size; size_with_insets(size) end
  def preferred_size; size_with_insets(size) end
end
