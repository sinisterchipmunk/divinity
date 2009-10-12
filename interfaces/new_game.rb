for_interface :new_game do
  images = Dir.glob("data/portraits/**/*").select { |fi| not (File.directory?(fi) or fi =~ /\.svn/) }
  cur_img = 0

  panel :center do
    layout :grid, 3, 12  # 3 wide, 12 high

    # Name
    panel [1, 2] do
      layout :grid, 2, 1
      label "Character Name:", :constraints => [0, 0]
      text_field actor(:player), :name, :constraints => [1, 0]
    end

    # Sex
    panel [1, 3] do
      layout :grid, World::Actor::SEXES.length, 1
      World::Actor::SEXES.each_with_index { |sex, x| radio_button actor(:player), :sex, sex, :constraints => [x, 0] }
    end

    # Portrait
    panel [1, 4..7] do  # This means to use grid location X1, Y4-7. Cool.
      layout :border
      label "Character Portrait:", :constraints => :north
      portrait = (image images[cur_img], :constraints => :center)
      panel :south do
        layout :grid, 2, 1
        button :previous, :constraints => [0, 0], :action => (proc do
          cur_img -= 1
          portrait.path = images[cur_img %= -images.length]
        end)
        button :next,     :constraints => [1, 0], :action => (proc do
          cur_img += 1
          portrait.path = images[cur_img %= images.length]
        end)
      end
    end

    # Back / Next
    panel [1, 8] do
      layout :grid, 2, 1 # 2 wide, 1 high
      button :cancel, :constraints => [0, 0], :action => :single_player
      button :continue, :constraints => [1, 0], :action => :attributes
    end
  end
end
