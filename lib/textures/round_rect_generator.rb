class Textures::RoundRectGenerator < Textures::TextureGenerator
  
  def initialize(opt = { })
    super(opt)
    @color_format = GL_RGBA
  end
  
  protected
  def define_defaults(options)
    #define a default set of options, if necessary
    defaults = { :interior_color => options[:fill_color] || '#ffffff',
                 :stroke_color => '#000000',
                 :opacity => 1,
                 :stroke_width => 1,
                 :width => 256,
                 :height => 256,
                 :fill_opacity => 1,
                 :radx => options[:radius] || 10,
                 :rady => options[:radius] || 10,
                 :stroke_opacity => 1,
                 :stroke_color => "#000000",
                 :stroke_width => 1,
                 :brightness => 1,
                 :hue => 1,
                 :saturation => 1,
                 :scale_or_tile => :scale,
                 :edge => true,
                 :raise_size => 6,
                 :raised => true
               }
    options.reverse_merge! defaults
  end
  
  def do_generation(options)
    #positioning variables
    x1 = options[:stroke_width]
    y1 = options[:stroke_width]
    x2 = options[:width]  - options[:stroke_width]
    y2 = options[:height] - options[:stroke_width]

    #create the canvas
    canvas = Magick::ImageList.new
    canvas.new_image(options[:width], options[:height])
    canvas.matte_reset! #Make all pixels transparent.
    #if options[:opacity] == 1 then canvas.alpha = DeactivateAlphaChannel
    #else canvas.alpha = ActivateAlphaChannel; end
    canvas.background_color = options[:background_color] if not options[:background_color].nil?

    bg = options[:background_image]
    if bg
      bg = bg.image_list
      if options[:scale_or_tile] == :scale
        bg = bg.resize options[:width], options[:height]
      else
        newbg = Magick::ImageList.new
        newbg.new_image(options[:width], options[:height])
        bg = newbg.composite_tiled!(bg, CopyCompositeOp)
      end

      if options[:edge]
        mask = Image.new(options[:width], options[:height]) { self.background_color = 'black' }
        gc = Draw.new
        gc.stroke('white').fill('white')
        gc.roundrectangle(x1+1, y1, x2-1, y2-2, options[:radx], options[:rady])
        gc.draw(mask)

        mask.matte = false
        bg.matte = true

        bg = bg.composite(mask, CenterGravity, CopyOpacityCompositeOp)
      end
      canvas = bg
    end
    draw = Magick::Draw.new

    #build the operations
    draw.fill         options[:interior_color] if not options[:interior_color].nil?
    draw.fill_opacity 0                        if     options[:interior_color].nil?
    draw.fill_opacity options[:fill_opacity]   if not options[:interior_color].nil?

    draw.stroke_opacity options[:stroke_opacity]
    draw.stroke         options[:stroke_color]
    draw.stroke_width   options[:stroke_width]

    #draw the rect
    draw.roundrectangle(x1, y1, x2, y2, options[:radx], options[:rady]) if options[:edge]

    begin
      #commit the above operations
      draw.draw(canvas)
      canvas = canvas.modulate options[:brightness], options[:saturation], options[:hue]
      if options[:raised]
        s = options[:raise_size]
        s = ((options[:width]-1)/2) if s > (options[:width]-1)/2
        s = ((options[:height]-1)/2) if s > (options[:height]-1)/2
        canvas = canvas.raise(s, s)
      end
    rescue ArgumentError => ae
      puts ae
    end

    #convert to binary string
    imgdata = canvas.to_blob { self.format = "PNG" }
    #convert binstr to raw data
    #for some reason the load_from_string alias isn't working
    surface = SDL::Surface.loadFromString((imgdata))
    
    #FIXME: And if I could get RMagick to give me raw data, I could load it directly with:
    #       SDL::load_from(imgdata, height, width, 32, width*4,
    #                      0xFF000000, 0x00FF0000, 0x0000FF00, 0x000000FF)
    #...and not have to worry about it any more. But then, if I could get the raw
    #data, I wouldn't need SDL at all, because OpenGL takes raw data as a parameter.
    return surface
  rescue
    puts "ERROR COMPUTING:\n#{options.to_yaml}"
    raise $!
  end
end