module Errors
  # this is so we can say things like Errors::EventNotRecognized instead of Errors::EventErrors::EventNotRecognized
  # -- it's a purely typing-friendly thing.
  include Errors::EventErrors
end
