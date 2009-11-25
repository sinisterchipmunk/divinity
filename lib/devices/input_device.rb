class Devices::InputDevice
  attr_reader :engine

  def initialize(engine)
    @engine = engine
  end
end
