module Helpers::EventListeningHelper
  def on(condition, &block)
    raise "Block expected" unless block_given?
    event_listeners(condition) << block
  end

  def fire_event(condition, *args)
    event_listeners(condition).each { |block| block.call(*args) }
  end

  def event_listeners(condition)
    @event_listeners ||= HashWithIndifferentAccess.new
    @event_listeners[condition] = [] unless @event_listeners[condition]
    @event_listeners[condition]
  end
end
