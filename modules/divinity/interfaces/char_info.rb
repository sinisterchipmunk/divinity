interface :char_info do
  images = Dir.glob("data/portraits/**/*").select { |fi| not (File.directory?(fi) or fi =~ /\.svn/) }
  cur_img = 0

  panel :center do
    layout :grid, 3, 10  # 3 wide, 10 high

    # Name
    panel [1, 2] do
      layout :grid, 2, 2
      label [0,0], "Character Name:"
      text_field [1,0], actor(:player), :name

      # Sex
      panel [0..1, 1] do
        layout :grid, World::Actor::SEXES.length, 1
        World::Actor::SEXES.each_with_index { |sex, x| radio_button [x,0], actor(:player), :sex, :value => sex }
      end
    end

    # Portrait
    panel [1, 3..7] do  # This means to use grid location X1, Y4-7. Cool.
      layout :border
      label :north, "Character Portrait:"
      portrait = image_selector :center, actor(:player), :portrait, :images => images
      panel :south do
        layout :grid, 2, 1
        button [0,0], :previous, :action => (proc do portrait.previous! end)
        button [1,0], :next,     :action => (proc do portrait.next! end)
      end
    end

    # Back / Next
    panel [1, 8] do
      layout :grid, 2, 1 # 2 wide, 1 high
      button [0,0], :cancel,   :action => :single_player
      button [1,0], :continue, :action => :attributes
    end
  end
end
