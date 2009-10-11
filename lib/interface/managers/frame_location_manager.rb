class Interface::Managers::FrameLocationManager
  attr_accessor :viewport

  def initialize
    @viewport = nil
    @xoffset = 10
    @yoffset = 10
    @index = 0
    @offset_count = 1
  end

  def request(size)
    ret = Geometry::Point.new
    @index += 1
    ret.x = @xoffset * @offset_count
    ret.y = @yoffset * @offset_count
    case @index
      when 1 then
      when 2 then
        ret.y = @viewport.height - (ret.y + size.height)
      when 3 then
        ret.x = @viewport.width  - (ret.x + size.width )
        ret.y = @viewport.height - (ret.y + size.height)
      when 4 then
        ret.x = @viewport.width  - (ret.x + size.width )
        @index = 0
        @offset_count += 1
    end
    ret
  end
end
