for_interface :attributes  do
  panel :center do
    rows = ((World::Actor::ATTRIBUTES.length+2 < 9) ? 9 : World::Actor::ATTRIBUTES.length+2)
    layout :grid, 3, rows + 3

    World::Actor::ATTRIBUTES.each_with_index do |ability, y|
      panel [1, y+2] do
        layout :grid, 2, 1
        label ability, :constraints => [0, 0]
        label nil, :constraints => [1, 0], :target => actor(:player), :method => ability
      end
    end

    panel [1, rows] do
      layout :grid, 3, 1
      button :store,  :constraints => [0, 0], :action => (proc { @attrs = actor(:player).attributes })
      button :reroll, :constraints => [1, 0], :action => (proc { actor(:player).reroll_attributes!  })
      button :recall, :constraints => [2, 0], :action => (proc { actor(:player).attributes = @attrs if @attrs })
    end

    panel [1, rows+1] do
      layout :grid, 2, 1
      button :back, :constraints => [0, 0], :action => :new_game
      button :continue, :constraints => [1, 0], :action => :race
    end
  end
end
