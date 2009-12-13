#ENV['DRY_RUN'] = "true"

require 'rubygems'
require 'test/unit'
require 'shoulda'

begin
  require 'test/unit/test_case'
rescue
  puts "Engine error occurred while loading: #{$!.message}"
  puts "Please report this error!"
  puts
  puts $!.backtrace
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
