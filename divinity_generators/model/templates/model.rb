class <%=class_name%> < Engine::Model::Base
<%attributes.each do |attribute| -%>
  attribute :<%=attribute%>
<%end -%>
end
