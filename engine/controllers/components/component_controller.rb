## Concept

class Components::ComponentController < Engine::Controller::Base
  helper :all
  
  append_view_path File.join(ENV['DIVINITY_ROOT'], "engine", "views")
end
