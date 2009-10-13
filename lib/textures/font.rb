class Textures::Font < Textures::TextureGenerator
  attr_reader :max_glyph_size

  @@instantiated_fonts = { }
  def self.select(options = { })
    options ||= { }
    @@instantiated_fonts[options.to_s] ||= self.new(options)
  end
  
  def initialize(opt = { })
    super
    @metrics = [ ]
    @max_glyph_size = Dimension.new
    @image_size = Dimension.new
    bind { } # generate the font
    @display_list = OpenGL::DisplayList.new(256) { |i| build_list(i) }
  end
  
  def sizeof(str)
    str = str.join("\n") if str.kind_of? Array
    size = Dimension.new
    size.height = self.height
    maxw = 0
    str.each_byte do |i|
      chr = i.chr
      if chr == "\n"
        size.height += self.height
        size.width = maxw if maxw > size.width
        maxw = 0
      else
        maxw += @metrics[i].width+2
      end
    end
    size.width = maxw if maxw > size.width
    size
  end

  def width(str)
    sizeof(str).width
  end
  
  def height
    @max_glyph_size.height
  end

  def put(x, y, str)
    str = str.to_s.split(/\n/) unless str.kind_of? Array
    
    bind do
      push_matrix do
        glTranslated(x, y, 0)
        str.each do |line|
          push_matrix { @display_list.call(line) }
          glTranslated(0, self.height, 0)
        end
      end
    end
  end

  def build_list(index)
    i = index
    return if i == 0
    tw  = (@max_glyph_size.width - 1)  / @image_size.width
    th  = (@max_glyph_size.height) / @image_size.height
    ch = i.chr
    metrics = @metrics[i]

    tx = (i % 16).to_i * (@max_glyph_size.width+1)
    ty = (i / 16).to_i * (@max_glyph_size.height+1)
    tx /= @image_size.width
    ty /= @image_size.height

    # we don't bind the texture here because it's bound in #put just once (as opposed to once per char if we do it here)
    glBegin(GL_QUADS)
      coord2f(tx+tw,    1-ty   ); glVertex2i(@max_glyph_size.width, @max_glyph_size.height)
      coord2f(tx+tw,    1-ty+th); glVertex2i(@max_glyph_size.width,                      0)
      coord2f(tx,       1-ty+th); glVertex2i(                    0,                      0)
      coord2f(tx,       1-ty   ); glVertex2i(                    0, @max_glyph_size.height)
    glEnd()
    glTranslatef(metrics.width+2, 0, 0)
  end
  
  protected
  def define_defaults(options)
    #define a default set of options, if necessary
    options[:dpi_x]          ||= 200
    options[:dpi_y]          ||= 200
    options[:fill_color]     ||= "#fff"
    options[:fill_opacity]   ||= 1
    options[:stroke_color]   ||= "transparent" #"#fff"
    options[:stroke_opacity] ||= 0
    options[:stroke_width]   ||= 0
    options[:family]         ||= "Arial"
    options[:style]          ||= "normal"#, italic, oblique, any
    options[:weight]         ||= 100
    options[:pointsize]      ||= 12
    options[:antialias]      ||= true
    options[:stretch]        ||= "normal"#, ultraCondensed, extraCondensed, condensed, semiCondensed, semiExpanded, expanded, extraExpanded, ultraExpanded, any
  end
  
  def do_generation(options)
    fn = "data/cache/font"
    options.sort { |a, b| a[0].to_s <=> b[0].to_s }.each { |n,v| fn = "#{fn}_#{n}-#{v}" }; fn = "#{fn}.png"
    if File.exists? fn
      blob = load_font(options, fn)
    else
      blob = gen_font(options)
      File.open(fn, "wb") { |file| file.print blob }
    end
    
    #convert binstr to raw data
    #for some reason the load_from_string alias isn't working
    surface = SDL::Surface.loadFromString(blob)
    
    #And if I could get RMagick to give me raw data, I could load it directly with:
    #       SDL::load_from(imgdata, height, width, 32, width*4,
    #                      0xFF000000, 0x00FF0000, 0x0000FF00, 0x000000FF)
    #...and not have to worry about it any more. But then, if I could get the raw
    #data, I wouldn't need SDL at all, because OpenGL takes raw data as a parameter.
    return surface
  end
  
  def build_metrics(draw, options, img = nil)
    draw.font_family = options[:family]
    draw.font_style = "Magick::#{options[:style].capitalize}Style".constantize
    draw.font_weight = options[:weight]
    draw.pointsize = options[:pointsize]
    draw.text_antialias = options[:antialias]
    draw.font_stretch = "Magick::#{options[:stretch][0].chr.capitalize+options[:stretch][1..options[:stretch].length]}Stretch".constantize

    max_descent = 0
    1.upto(255) do |i|
      if img then @metrics[i] = draw.get_type_metrics(img, i.chr)
      else @metrics[i] = draw.get_type_metrics(i.chr); end
      @max_glyph_size.width  = @metrics[i].max_advance if @max_glyph_size.width  < @metrics[i].max_advance
      @max_glyph_size.height = @metrics[i].height      if @max_glyph_size.height < @metrics[i].height
      max_descent = @metrics[i].descent if max_descent > @metrics[i].descent
    end
    
    max_descent
  end
  
  def load_font(options, fn)
    img = ImageList.new(fn)
    @image_size.width = img.columns
    @image_size.height = img.rows
    
    build_metrics(Magick::Draw.new, options, img)
    
    img.to_blob
  end
  
  def gen_font(options)
    draw = Magick::Draw.new

    #set the options
    draw.fill         options[:fill_color]   if not options[:fill_color].nil?
#    draw.fill_opacity 0                      if     options[:fill_color].nil?
    draw.fill_opacity options[:fill_opacity] if not options[:fill_color].nil?
    draw.stroke_opacity options[:stroke_opacity]
    draw.stroke         options[:stroke_color]
    draw.stroke_width   options[:stroke_width]
    
    max_descent = build_metrics(draw, options)
                          #for old video cards
    @image_size.width  = next_pow2(@max_glyph_size.width.to_i  * 16)
    @image_size.height = next_pow2(@max_glyph_size.height.to_i * 16)
    
    #create the canvas
    canvas = Magick::ImageList.new
    canvas.new_image(@image_size.width, @image_size.height)
    canvas.x_resolution = options[:dpi_x]
    canvas.y_resolution = options[:dpi_y]
    canvas.matte_reset! #Make all pixels transparent.
    
    #draw each character
    1.upto 255 do |c|
      i = c.to_i
      x = (i % 16).to_i * (@max_glyph_size.width+1)
      y = (i / 16).to_i * (@max_glyph_size.height+1)
#      puts @max_descent
      y += max_descent
      
      str = i.chr
      "[]\\".each_byte do |ch|
        if str == ch.chr
          str = "\\#{str}"
          x -= @metrics[?\\.to_i].width
        end
      end
      str.sub!(/%/, '%%')
      draw.text(x, y, str)
    end

    #commit the above operations
    draw.draw(canvas)

    #convert to binary string
    canvas.to_blob { self.format = "PNG" }
  end
  
  def next_pow2(val)
    val -= 1
    val = (val >> 1) | val
    val = (val >> 2) | val
    val = (val >> 4) | val
    val = (val >> 8) | val
    val = (val >> 16) | val
    val = (val >> 32) | val
    val += 1
    
    val
  end
end