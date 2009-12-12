module Engine::Delegation
  # Camera methods
  delegate :strafe!, :move_to!, :translate_to!, :translate!, :look!, :move!, :look_at!,
           :strafe, :move_to, :translate_to, :translate, :move, :look_at, :rotate_view,
           :lock_up_vector?, :lock_up_vector!, :lock_y_axis?, :lock_y_axis!,
           :point_visible?, :cube_visible?, :sphere_visible?, :rotate_view!, :to => :camera

  def write(x, y, text, options = {})
    w = self.width
    h = self.height
    font = Textures::Font.select(options)
    valid_x = [:east,  :west,  :center, :right, :left,   :middle]
    valid_y = [:north, :south, :center, :top,   :bottom, :middle]
    size = font.sizeof(text)

    case x
      when :west,   :left   then x = 0
      when :east,   :right  then x = w - size.width
      when :center, :middle then x = (w - size.width) / 2
      else raise "X coordinate must be an integer or one of #{valid_x.inspect}" unless x.kind_of? Fixnum
    end

    case y
      when :north, :top     then y = 0
      when :south, :bottom  then y = h - size.height
      when :center, :middle then y = (h - size.height) / 2
      else raise "X coordinate must be an integer or one of #{valid_y.inspect}" unless x.kind_of? Fixnum
    end

    ortho(w, h) do
      font.put(x, y, text)
    end
  end
end
