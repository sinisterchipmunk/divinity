require 'test_helper'

class AnotherTest < Test::Engine::TestCase
  def setup
    controller "another"
  end
  
  def test_test_works
    action :test
    assert true
  end
  
end
