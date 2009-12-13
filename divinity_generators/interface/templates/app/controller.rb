# TODO: Applications need an InterfaceController for the interface-equivalent of ApplicationController.
# If you didn't understand that, then don't sweat it.

class Interfaces::<%=class_name%>Controller < Engine::Controller::Base
<%actions.each do |action| -%>
  def <%=action%>
  end

<%end -%>
end
