class Resource::Theme::Effects::ButtonEffect < Resource::Theme::Effects::Effect
  # this is completely optional, but does some extra validation and produces more intelligible error messages
  # if the effect is called improperly.
  args 0 => Symbol, 1 => Numeric, 2 => Numeric
  num_args 1..3

  def apply(image, type, width = 3, height = 3)
    width = (width*2).min(image.columns)/2
    height = (height*2).min(image.rows)/2

    result = case type
      when :outset, :raise, :raised then image.raise(width, height, true)
      when :inset, :lower, :lowered then image.raise(width, height, false)
      else raise "Valid types: [:outset, :raise, :raised]; [:inset, :lower, :lowered]"
    end
    image.composite!(result, 0, 0, Magick::CopyCompositeOp)
  end
end
