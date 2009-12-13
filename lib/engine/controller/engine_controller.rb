# An EngineController is just like a regular Controller, except that it needs to be able to A) not render its
# result immediately (because OpenGL may not be ready for it) and B) render its result every frame.
#
# It has a single reserved method name, "update", which is used to perform processing between frames. You can
# explicitly tell "update" to render a view, but if you don't, then it will simply continue rendering the previous
# action (but, obviously, any variables you've changed will stay changed).
#
class Engine::Controller::EngineController < Engine::Controller::Base
  def render_view(path, locals = {})
    @performed_render = true
    response.view.path = path
    response.view.locals = locals
    response.process(:defer_rendering => true)
  rescue Engine::View::MissingViewError => err
    # Fail silently if an update view can't be found -- but only if it's the Update view :)
    unless action_name == 'update' and err.message =~ /\/update\.rb/
      raise
    end
  end

  private
    def default_view(action_name = self.action_name)
      super(action_name, action_name)
    rescue Engine::View::MissingViewError => err
      raise unless action_name == 'update' and err.message =~ /\/update\.rb/
      super(@previous_action, action_name)
    end

    def initialize_view
      if action_name != 'update'
        if @previous_action != action_name && @previous_action.blank?
          response.view = Engine::View::EngineView.new(self)
          response.view.helpers.send :include, self.class.master_helper_module
        end
        @previous_action = action_name
      end
      erase_results
    end
end
