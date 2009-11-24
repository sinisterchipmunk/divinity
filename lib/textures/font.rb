class Textures::Font < Textures::TextureGenerator
  attr_reader :max_glyph_size

  # It's dangerous to let the width and height methods face public because they are A) of extremely limited public use
  # and B) they can be easily confused with line_height and text_width.
  protected :width
  protected :height

  @@instantiated_fonts = HashWithIndifferentAccess.new
  def self.select(options = { })
    options ||= { }
    @@instantiated_fonts[options.sort { |a,b| a[0].to_s <=> b[0].to_s }.to_s] ||= self.new(options)
  end

  # Causes all fonts to be invalid, forcing them to be recreated the next time they are used.
  def self.invalidate!
    @@instantiated_fonts.each do |options, font|
      font.invalidate!
    end
  end
  
  def initialize(opt = { })
    super()
    @metrics = [ ]
    @max_glyph_size = Dimension.new
    image # generate the font
    @display_list = OpenGl::DisplayList.new(256) { |i| build_list(i) }
  end
  
  def sizeof(str)
    str = str.join("\n") if str.kind_of? Array
    size = Dimension.new
    size.height = self.line_height
    maxw = 0
    str.each_byte do |i|
      chr = i.chr
      if chr == "\n"
        size.height += self.line_height
        size.width = maxw if maxw > size.width
        maxw = 0
      else
        maxw += @metrics[i].width+2
      end
    end
    size.width = maxw if maxw > size.width
    size
  end

  # causes this font to be invalid, forcing it to be recreated the next time it is used.
  def invalidate!
    free_resources
    @display_list.rebuild!
  end

  def text_width(str)
    sizeof(str).width
  end
  
  def line_height
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
    tw  = (@max_glyph_size.width - 1)  / width
    th  = (@max_glyph_size.height) / height
    ch = i.chr
    metrics = @metrics[i]

    tx = (i % 16).to_i * (@max_glyph_size.width+1)
    ty = (i / 16).to_i * (@max_glyph_size.height+1)
    tx /= width
    ty /= height

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
  def default_options
    #define a default set of options
    {
      :dpi_x => 200,
      :dpi_y => 200,
      :fill_color => "#fff",
      :fill_opacity => 1,
      :stroke_color => 'transparent',
      :stroke_opacity => 0,
      :stroke_width => 0,
      :family => 'Arial',
      :style => 'normal', #italic, oblique, any
      :weight => 100,
      :pointsize => 12,
      :antialias => true,
      :stretch => 'normal', # ultraCondensed, extraCondensed, condensed, semiCondensed, semiExpanded, expanded,
                            # extraExpanded, ultraExpanded, any
    }
  end
  
  def do_generation(options)
    fn = "data/cache/font"
    options.sort { |a, b| a[0].to_s <=> b[0].to_s }.each { |n,v| fn = "#{fn}_#{n}-#{v}" }; fn = "#{fn}.png"
    if File.exists? fn
      load_font(options, fn)
    else
      gen_font(options)
      File.open(fn, "wb") { |file| file.print self.image.to_blob { self.format = 'PNG' } }
    end
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

    build_metrics(Magick::Draw.new, options, img)
    
    self.image = img
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
    width  = next_pow2(@max_glyph_size.width.to_i  * 16)
    height = next_pow2(@max_glyph_size.height.to_i * 16)
    
    #create the canvas
    canvas = Magick::ImageList.new
    canvas.new_image(width, height)
    canvas.x_resolution = options[:dpi_x]
    canvas.y_resolution = options[:dpi_y]
    canvas.matte_reset! #Make all pixels transparent.
    
    #draw each character
    1.upto 255 do |c|
      i = c.to_i
      x = (i % 16).to_i * (@max_glyph_size.width+1)
      y = (i / 16).to_i * (@max_glyph_size.height+1)
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
    self.image = canvas
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