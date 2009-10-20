module Engine::DefaultGui
  attr_reader :frame
  @@interface_builders = HashWithIndifferentAccess.new

  include Interface::Containers
  include Interface::Layouts

  delegate :add, :to => :interface

  def init_default_gui
    @frame = Frame.new(:title_bar => false, :pinned => true) do |i|
      i.location = [0, 0]
      i.size = [width, height]
      i.layout = BorderLayout.new
      i.root_panel.background_visible = false
    end

    frame_manager.theme = theme(:default)
    frame_manager.add frame
    assume_interface :main_menu
  end
  
  def assume_interface(name)
    frame.remove_all_components
    frame.background_visible = true
    frame.location = [0, 0]
    frame.size = [width, height]
    frame.layout = Interface::Layouts::BorderLayout.new
    pause!
    find_interface(name).apply_to(self, frame)
  end

  def find_interface(name)
    raise "Interface not found: #{name}" unless @@interface_builders[name]
    @@interface_builders[name]
  end

  def fire_interface_action(action)
    return action.call(self) if action.kind_of? Proc
    case action
      when :quit then stop!
      else assume_interface(action)
    end
  end

  def self.interface(name, &blk)
    @@interface_builders[name] = Interface::Builder.new(&blk)
  end

  Dir.glob("modules/*/interfaces/*.rb").each do |fi|
    next if File.directory? fi or fi =~ /\.svn/
    eval File.read(fi), binding, fi, 1
  end
end
