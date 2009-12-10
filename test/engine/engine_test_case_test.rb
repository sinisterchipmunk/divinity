require 'test_helper'

class EngineTestCaseTest < Test::Engine::TestCase
  def setup
    puts "Engine test case setup"
  end

  def teardown
    puts "Engine test case teardown"
  end

  def test_engine_test_case_works
    puts "It's working"
  end
end
