module Physics::Rope::RopePhysics
  class Link
    attr_accessor :siblings
    attr_accessor :position

    def initialize
      @position = Math::Vector.new
      @siblings = [ ]
      @last_time = Time.now
    end
  end

  def update(scene)
    super
  end

  attr_accessor :links
end
