class Components::ComponentController < Engine::Controller::Base
  helper :all
  
  append_view_path File.join("app/interface/views")

  # When an event is fired, we should expect the standard event functionality (via #on), but additionally,
  # the parent controller should receive the event automatically as an action. If the parent doesn't respond
  # to the event, then it is sent to the parent's parent, and so on until something responds or the root element
  # has been reached. If nothing receives the event, it should fail silently because it's apparently a nonessential
  # result.
  def process_event(*a)
    parent.process_event(*a) if parent
    super
  end
end
