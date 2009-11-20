interface :character_class do
  panel :center do
    layout :grid, 3, 1
    panel [0, 0] do
      layout :border
      panel :north do
        layout :grid, 2, 1
        partial [0,0], :char_info_sm
        text_area [1,0], actor(:player), :attribute_string
      end
      partial :center, :race_sm
    end

    flip_panel [1..2, 0], actor(:player), :character_class do
      character_classes.each do |id, cclass|
        panel id do
          layout :border
          label :north, cclass.name
          panel :center do
            layout :border
            text_area :west, cclass, :description
            panel :east do
              layout :grid, 1, 2
              if File.exist? "data/character_classes/#{id}.jpg"
                image [0, 0], "data/character_classes/#{id}.jpg"
              end
              text_area [0, 1], cclass, :summary
            end
          end
        end
      end
    end
  end
  
  panel :south do
    layout :grid, 2, 1
    button [0,0], :back, :action => :race
    button [1,0], :next, :action => :gameplay
  end
end