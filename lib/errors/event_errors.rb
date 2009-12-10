module Errors::EventErrors
  class EventError < RuntimeError
  end

  class EventNotRecognized < EventError
  end
end
