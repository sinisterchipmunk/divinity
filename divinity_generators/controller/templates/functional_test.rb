require 'test_helper'

class <%=class_name%>Test < Test::Engine::TestCase
  def setup
    controller "<%=file_name%>"
  end
  <%actions.each do |action|%>
  def test_<%=action%>_works
    action :<%=action%>
    assert true
  end
  <%end%>
end
