require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'divinity_engine'

class Test::Unit::TestCase
  def setup
    @engine = DivinityEngine.new(:dry_run => true)
  end

  def teardown
    @engine.stop!
  end
end

module Test::Unit::Assertions
  def assert_length(n, arr)
    assert_equal n, arr.length
  end

  def assert_less_than(lhs, rhs, message = "")
    message = "#{lhs} < #{rhs}" if message.blank?
    assert lhs < rhs, message
  end

  def assert_greater_than(lhs, rhs, message = "")
    message = "#{lhs} > #{rhs}" if message.blank?
    assert lhs < rhs, message
  end

  def assert_less_than_or_equal_to(lhs, rhs, message = "")
    message = "#{lhs} <= #{rhs}" if message.blank?
    assert lhs <= rhs, message
  end

  def assert_greater_than_or_equal_to(lhs, rhs, message = "")
    message = "#{lhs} >= #{rhs}" if message.blank?
    assert lhs >= rhs, message
  end

  alias assert_le assert_less_than_or_equal_to
  alias assert_ge assert_greater_than_or_equal_to
end
