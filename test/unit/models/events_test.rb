require 'test_helper'

class EventsTest < Test::Unit::TestCase
  def test_events_can_be_found
    assert_not_nil Events
    assert_not_nil Events::ControllerCreatedEvent
    assert_not_nil Events::FocusEvent
    assert_not_nil Events::InterfaceAssumed
    assert_not_nil Events::Redirected
    assert_not_nil Events::KeyEvent
    assert_not_nil Events::KeyPressed
    assert_not_nil Events::KeyReleased
    assert_not_nil Events::MouseEvent
    assert_not_nil Events::MouseButtonEvent
    assert_not_nil Events::MouseMoved
    assert_not_nil Events::MousePressed
    assert_not_nil Events::MouseReleased
  end
end
