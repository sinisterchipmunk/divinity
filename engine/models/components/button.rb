## Concept

class Components::Button < Engine::Model::Base
  attr_accessor :state
  attr_accessor :caption

  def initialize
    @caption = "Untitled"
  end
end
