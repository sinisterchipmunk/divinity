module Components::ComponentHelper
  def theme(which)
    
  end

  def paint_background(options = {})
    gc = response.graphics_context
  end
  
  def text(text, x = :center, y = :center)
    case x
      when :left, :west then x = :west
      when :center
      when :right, :east then x = :east
      else raise ArgumentError, "Expected x to be one of [:west, :center, :east, :left, :right]; found #{x.inspect}"
    end if x.kind_of? Symbol

    case y
      when :top, :north then x = :north
      when :center
      when :bottom, :south then x = :south
      else raise ArgumentError, "Expected y to be one of [:north, :center, :south, :top, :bottom]; found #{y.inspect}"
    end if y.kind_of? Symbol

    #Font.select.put(x, y, text)
  end
end
