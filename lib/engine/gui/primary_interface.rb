#This was going to be the game interface, but it turned into a test of the UI system instead. The interface
# itself will be defined in a more extensible way.

class Engine::GUI::PrimaryInterface
  # game, menu, map, journal, inventory, character sheet, spells, rest
  # game time, (talk, attack, stop, formations / class-specific), AI on/off, select all
  # party members
  
  include Geometry
  include Interface::Components
  include Interface::Containers
  include Interface::Layouts
  attr_reader :frame_manager, :frame

  Interface::Layouts::BorderLayout
  Interface::Layouts::GridLayout
  Interface::Containers::Frame
  Interface::Containers::Panel
  Interface::Components::ImageButton

  def initialize(frame_manager)
    @frame_manager = frame_manager
    @frame = Frame.new(:title_bar => false, :pinned => true)
    @other_frame = Frame.new do |i|
	    i.size = [ 200, 200 ]
	    i.location = [200, 200]
    end

    @frame_manager.add @other_frame

    frame.location = Point.new(0, 0)
    frame.size = Dimension.new(width, height)
    
    frame.root_panel.border_size = 0
    frame.root_panel.background_visible = false
    frame.layout = BorderLayout.new

    west = Panel.new(BorderLayout.new)
    east = Panel.new(BorderLayout.new)
    south = Panel.new(BorderLayout.new)
    center = Panel.new(BorderLayout.new)

    frame.add west, "West"
    frame.add east, "East"
    frame.add south, "South"
    frame.add center, "Center"

    viewport = Panel.new(BorderLayout.new)
    feedback = Panel.new(BorderLayout.new)
    viewport.visible = false
    viewport.enabled = false
    center.background_visible = false
    center.border_size = 0
    center.add viewport, "Center"
    center.add feedback, "South"

    left = right = nil
    arrows = Panel.new(BorderLayout.new) do |a|
      a.add((left = ImageButton.new("data/ui/arrow_left.png")), "West")
      a.add((right = ImageButton.new("data/ui/arrow_right.png")), "East")
    end
    left.enabled = false
    left.edge = false
    right.edge = false

    portraits = Panel.new(GridLayout.new) do |p|
      add_image_button(p, ImageButton.new("data/portraits/SAFANAM.bmp"), [0, 0])
      add_image_button(p, ImageButton.new("data/portraits/NMINSCM.bmp"), [0, 1])
      add_image_button(p, ImageButton.new("data/portraits/NJAHEIRM.bmp"), [0, 2])
      add_image_button(p, ImageButton.new("data/portraits/NANOMENM.bmp"), [0, 3])
      add_image_button(p, ImageButton.new("data/portraits/NAERIEM.bmp"), [0, 4])
      add_image_button(p, ImageButton.new("data/portraits/NVICONM.bmp"), [0, 5])
    end
    east.add portraits, "Center"
    east.add arrows, "South"
  end

  def attach!
    frame_manager.add frame
  end

  def detach!
    frame_manager.remove frame
  end

  delegate :width, :height, :to => :frame_manager

  private
  def add_image_button(p, b, c)
    p.add b, c
  end
end
