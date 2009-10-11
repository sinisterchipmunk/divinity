class Interface::Themes::DefaultTheme
  attr_reader :options

  def initialize
    @options = { }
    @options[:default] = {
      :radx => 0,
      :rady => 0,
      :stroke_color => "black",#"#770013",
      :stroke_width => 1,
      :stroke_opacity => 1,
      :text_background_color => "#eeeeee"
    }

    @options[:primary] = {
      :background_image => Resources::Image.new("data/ui/background.bmp"),
      :scale_or_tile => :tile,
      :fill_opacity => 0.2,
      :fill_color => 'green',
      :stroke_color => nil,#"#770013",
      :stroke_width => 0,
      :stroke_opacity => 0.0,
      :raised => true
    }

    @options[:secondary] = {
      :fill_color => '#cccccc',
      :radx => 8,
      :rady => 8,
      :stroke_color => 'black'
    }

    @options[:text] = {
      :fill_color => '#eeeeee',
      :radx => 0,
      :rady => 0,
      :stroke_color => 'black',
      :raised => false
    }
  end

  def select(type = :default)
    (@options[type] || {}).reverse_merge(@options[:default])
  end
end
