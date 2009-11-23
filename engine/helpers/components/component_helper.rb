module Components::ComponentHelper
  def paint_background(options = {})
    draw.fill "#ff0000cc"
    draw.stroke "#99000099"
    draw.roundrectangle(0, 0, width, height, 10, 10)
  end

  def text(text, x = :center, y = :center)
    dims = Textures::Font.select.sizeof(text)

    case x
      when :left, :west  then x = 0
      when :center       then x = center.x - dims.width / 2
      when :right, :east then x = width - dims.height
      else raise ArgumentError, "Expected x to be one of [:west, :center, :east, :left, :right]; found #{x.inspect}"
    end if x.kind_of? Symbol

    case y
      when :top, :north    then y = 0
      when :center         then y = center.y - dims.height / 2
      when :bottom, :south then y = height - dims.height
      else raise ArgumentError, "Expected y to be one of [:north, :center, :south, :top, :bottom]; found #{y.inspect}"
    end if y.kind_of? Symbol

    draw.stroke "black"
    draw.fill "black"
    draw.text(x, y, text)
  end

  def draw(*a, &b)
    response.draw(*a, &b)
  end
end
