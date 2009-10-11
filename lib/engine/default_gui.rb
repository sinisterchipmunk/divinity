module Engine::DefaultGUI
  attr_reader :interface
  @@interface_builders = HashWithIndifferentAccess.new

  include Interface::Containers
  include Interface::Layouts

  delegate :add, :to => :interface

  def init_default_gui
    #interface = 	  Engine::GUI::PrimaryInterface.new(frame_manager)
    #interface.attach!
    @interface = Frame.new(:title_bar => false, :pinned => true) do |i|
      i.location = [0, 0]
      i.size = [width, height]
      i.layout = BorderLayout.new
      i.root_panel.background_visible = false
    end

    frame_manager.add interface

    assume_interface :main_menu
  end
  @@interface_builders ||= HashWithIndifferentAccess.new

  def assume_interface(name)
    raise "Interface not found: #{name}" unless @@interface_builders[name]
    interface.remove_all_components
    @@interface_builders[name].apply_to(self, interface)
  end

  def fire_interface_action(action)
    case action
      when :quit then stop!
      else assume_interface(action)
    end
  end

  def self.for_interface(name, &blk)
    @@interface_builders[name] = Interface::Builder.new(&blk)
  end

  Dir.glob("interfaces/*.rb").each do |fi|
    next if File.directory? fi or fi =~ /\.svn/
    eval File.read(fi), binding, __FILE__, __LINE__
  end
end
