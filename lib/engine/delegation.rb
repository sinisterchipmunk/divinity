module Engine::Delegation
  delegate :maintain_up_vector?, :maintain_up_vector!, :lock_x_axis?, :lock_x_axis!, :point_visible?, :cube_visible?,
           :sphere_visible?, :rotate_view!, :to => :camera

  def write(x, y, text)
    w = self.width
    h = self.height

    case x
      when :west, :left  then x = 0
      when :east, :right then x = w - Textures::Font.select.width(text)
      else raise "X coordinate must be an integer or one of [:east, :west, :right, :left]" unless x.kind_of? Fixnum
    end

    case y
      when :north, :top    then y = 0
      when :south, :bottom then y = h - Textures::Font.select.height
      else raise "X coordinate must be an integer or one of [:north, :south, :top, :bottom]" unless x.kind_of? Fixnum
    end

    ortho(w, h) do
      Textures::Font.select.put(x, y, text)
    end
  end
end
