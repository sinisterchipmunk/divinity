# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < Engine::Controller::EngineController
  helper :all # include all helpers, all the time
end
