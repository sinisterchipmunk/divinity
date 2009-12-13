require 'test_helper'

class <%=class_name%>Test < Test::Engine::TestCase
  def setup
    controller "<%=file_name%>"
  end

  def test_index_works
    action :index
    assert true
  end
end
