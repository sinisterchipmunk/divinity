module Components::ComponentHelper
  # delegate these methods into response
  def graphics_context; response.graphics_context end
  def colorize!(color, amount) response.colorize!(color, amount) end

  # options used are (:image, :mode, :effect[s])
  # the :effect[s] option is passed into #paint_effect!
  def paint_background(options = HashWithIndifferentAccess.new)
    options.reverse_merge! theme[:background] if theme[:background]
    if options
      if image = options[:image]
        image = Textures::Texture.new(engine.find_file(image)).send(:image)#engine.image(options[:image]).image_list
        if options[:mode] == :tile or options[:mode].nil?
          graphics_context.composite_tiled!(image, OverCompositeOp)#AtopCompositeOp)
        else #scale
          image.resize!(width, height)
          graphics_context.composite!(image, 0, 0, OverCompositeOp)#AtopCompositeOp)
        end
      end
      if arr = options[:effect] || options[:effects]
        paint_effects! graphics_context, arr
      end
    end
  end

  # paints the specified effect or Array of effects to the specified image.
  def paint_effects!(image, *effects)
    effects.flatten.each { |effect| effect.apply_to(image) }
  end

  # paints the list of effects to this image. Note that this does not count backgroud effects, which are
  # added at the end of #paint_background.
  def paint_effects(effects = Array.new)
    effects.concat(theme[:effect] ? [theme[:effect]] : [])
    effects.concat((theme[:effects].kind_of? Array) ? theme[:effects] : [theme[:effects]]) if theme[:effects]
    paint_effects! graphics_context, *effects
  end

  # options used are (:style, :color); tries to guess these from theme settings if they're not found.
  # Also makes use of theme[:background], theme[:stroke].
  def paint_border(options = HashWithIndifferentAccess.new)
    options.reverse_merge! theme[:border] if theme[:border]
    options[:style] = :none if options[:style].nil?
    return if options[:style] == :none

    # first we need a stencil
    d = Magick::Draw.new
    theme.apply_to(d)
    d.fill("white")
    d.stroke("transparent")
    paint_border!(options[:style], d)
    stencil = Magick::Image.new(width, height)
    stencil.matte_reset!
    d.draw(stencil)

    # now we place the graphics context over the stencil, causing any areas blocked (transparent pixels) by the stencil
    # to be blocked in the graphics context
    stencil.composite!(graphics_context, 0, 0, AtopCompositeOp)

    # then we need to retrace the border, this time using the colors we want
    d = Magick::Draw.new
    theme.apply_to(d)
    d.fill(theme[:background][:color]) if theme[:background] and theme[:background][:color]
    d.stroke(options[:color] || theme[:stroke][:color]) if options[:color] || (theme[:stroke] && theme[:stroke][:color])
    paint_border!(options[:style], d)

    # finally, we can composite the stencil (which is now the actual image) back into the graphics context (which is
    # useless), and then commit the border to the finished product.
    graphics_context.composite!(stencil, 0, 0, CopyCompositeOp)
    d.draw(graphics_context)
  end

  # Paints the border of this component without creating a stencil or applying the changes to the graphics context.
  # Expects a style, which is a symbol such as :round_rect, :rectangle, etc., and a Magick::Draw object to draw the
  # border to.
  def paint_border!(style, d)
    case style
      when :round_rect then d.roundrectangle(0, 0, width, height, 10, 10)
      # default is :round_rect, but treat anything unrecognized as :rectangle (use entire image)
      else d.rectangle(0, 0, width, height)
    end
  end

  # options used are (:stroke, :color) and the current theme[:font] options.
  # Also makes use of theme[:fill], theme[:stroke].
  def text(text, x = :center, y = :center, options = HashWithIndifferentAccess.new)
    font = theme.font
    unless options.empty?
      options.reverse_merge! theme[:font]
      font = Font.select(options)
    end
    dims = font.sizeof(text)

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

    draw.stroke options[:stroke] || "transparent"
    draw.fill options[:color] || theme[:font][:color] if options[:color] || theme[:font][:color]
    draw.text(x, y, text)
    draw.fill theme[:fill][:color] if theme[:fill] and theme[:fill][:color]
    draw.stroke theme[:stroke][:color] if theme[:stroke] and theme[:stroke][:color]
  end

  def draw(*a, &b)
    response.draw(*a, &b)
  end
end
