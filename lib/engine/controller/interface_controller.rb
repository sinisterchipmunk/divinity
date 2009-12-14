# InterfaceControllers are the UI logic of the engine. They are used to provide a graphical user interface (GUI) for
# the user to interact with the engine through.
#
# InterfaceControllers differ from EngineControllers in several ways. First, they do not have a #update method that
# fires between every frame; when their actions fire, the result is recorded to an offscreen buffer, and that buffer
# is rendered every frame until something event occurs to cause another action to be fired.
#
# Interface actions are fired solely through interaction with the user in the form of Events. The "index" action is
# fired when the interface is initially loaded, and then other methods can fire depending on how the user interacts
# with the interface. For instance, if the user clicks the mouse button, the "mouse_clicked" action will fire. If the
# user types a key, the "key_typed" action will fire. Additionally, interfaces can receive events fired by their
# subcomponents. As an example, if you add a Button to your interface, then your interface can listen for
# "button_clicked" actions to fire. The params[:event] object always holds the last event, which contains information
# about exactly which button was pressed, or which key was pressed. You can also interface with the Keyboard and
# Mouse inputs directly via #keyboard and #mouse.
#
class Engine::Controller::InterfaceController < Engine::Controller::Base
  hide_action :initialize_view

  def initialize_view
    super
    singleton_class = class << response.view; self; end
    singleton_class.send(:include, Helpers::ComponentHelper)
  end
end
