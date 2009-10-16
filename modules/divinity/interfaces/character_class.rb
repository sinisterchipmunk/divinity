interface :character_class do
  panel :center do
    layout :grid, 3, 1
    panel [0, 0] do
      layout :border
      panel :north do
        layout :grid, 2, 1
        partial :char_info_sm, [0,0]
        text_area actor(:player), :attribute_string, [1,0]
      end
      partial :race_sm, :center
    end

    flip_panel [1..2, 0] do
      character_classes.each do |id, cclass|
        panel do
          layout :border
          label cclass.name, :north
          panel :center do
            layout :border
            text_area cclass, :description, :constraints => :west
            panel :east do
              layout :grid, 1, 2
              image "data/character_classes/#{id}.jpg", :constraints => [0, 0]
              text_area cclass, :summary, :constraints => [0, 1]
            end
          end
        end
      end
    end
  end
  
  panel :south do
    layout :grid, 2, 1
    button :back, :constraints => [0,0], :action => :race
    button :next, :constraints => [1,0], :action => :something_after_class
  end
end