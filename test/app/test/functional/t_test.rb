require 'test_helper'

class TTest < Test::Engine::TestCase
  def setup
    controller "t"
  end
  
  def test_index_works
    action :index
    assert true
  end
  
end
