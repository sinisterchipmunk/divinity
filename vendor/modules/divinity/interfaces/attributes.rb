interface :attributes do
  panel :west do
    partial :center, :char_info_sm
  end

  panel :center do
    rows = ((World::Actor::ATTRIBUTES.length+2 < 9) ? 9 : World::Actor::ATTRIBUTES.length+2)
    layout :grid, 3, rows + 3

    World::Actor::ATTRIBUTES.each_with_index do |ability, y|
      panel [1, y+2] do
        layout :grid, 2, 1
        label [0,0], ability
        label [1,0], actor(:player), ability
      end
    end

    panel [1, rows] do
      layout :grid, 3, 1
      button [0,0], :store,  :action => (proc { @attrs = actor(:player).attributes })
      button [1,0], :reroll, :action => (proc { actor(:player).reroll_attributes!  })
      button [2,0], :recall, :action => (proc { actor(:player).attributes = @attrs if @attrs })
    end

    panel [1, rows+1] do
      layout :grid, 2, 1
      button [0,0], :back,     :action => :char_info
      button [1,0], :continue, :action => :race
    end
  end
end
