# This plugin is mixed into DivinityEngine and is responsible for providing a way to old with the various
# controllers. It is initially called from Engine::ContentLoader.
#
module Engine::Controller::Routing
  def assume_interface(id, *args)
    klass = find_controller_class(id)
    options = args.extract_options!
    action = options.delete(:action)
    event = options.delete(:event)

    cur = current_interface
    instance = find_controller_instance(klass, *[args, options])
    event ||= Events::InterfaceAssumed.new(cur, instance.action_name, instance, action)

    # Dispatch a focus event to both controllers if they're not the same thing
    if cur != instance
      evt = Events::FocusEvent.new(cur, instance)
      cur.process_event(:focus_lost, evt) if cur
      instance.process_event(:focus_gained, evt)
      self.current_controller = instance
    end

    # A freshly initialized root old is not going to include an action, and should already be pointed at 'index'
    # so we don't do anything if action is undefined.
    self.current_controller.process(action, event) unless action.nil?
  end

  def current_interface() current_controller end
  def root_interface() current_controller end

  def find_controller_instance(id, *args)
    klass = find_controller_class(id)

    # If we have a running instance of klass, we should switch over to it.
    # If not, we should construct request and response objects and instantiate the controller.
    @instantiated_controllers ||= Hash.new
    instance = if @instantiated_controllers.keys.include? klass then
      instance = @instantiated_controllers[klass]
      instance
    else
      request = Engine::Controller::Request.new(self, Geometry::Rectangle.new(0,0,width,height), *args)
      response = Engine::Controller::Response.new
      instance = @instantiated_controllers[klass] = klass.new(self, request, response)
      instance.process('index', Events::ControllerCreatedEvent.new(instance))
      instance
    end

    instance
  end

  def dispatch_event(type, event)
    fire_event type, event unless paused?
    current_interface.dispatch_event type, event if current_interface
  end

  alias find_interface find_controller_instance

  def find_controller_class(id)
    id = id.to_s if id.kind_of? Symbol
    if id.kind_of? String
      id = id.camelize
      id = "#{id.camelize}Controller" unless id.ends_with?("Controller")
      id = id.constantize
    end
    id
  end
end
