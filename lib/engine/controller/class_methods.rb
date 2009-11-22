module Engine::Controller::ClassMethods
  def root(a = nil)
    r = Engine::Controller::Base.instance_variable_get("@root")
    r = a ? a : r
    Engine::Controller::Base.instance_variable_set("@root", r)
  end

  def controller_class_name
    @controller_class_name ||= name.demodulize
  end

  # Converts the class name from something like "OneModule::TwoModule::NeatController" to "neat".
  def controller_name
    @controller_name ||= controller_class_name.sub(/Controller$/, '').underscore
  end

  # Converts the class name from something like "OneModule::TwoModule::NeatController" to "one_module/two_module/neat".
  def controller_path
    @controller_path ||= name.gsub(/Controller$/, '').underscore
  end

  def view_paths
    read_inheritable_attribute(:view_paths) || write_inheritable_attribute(:view_paths, Engine::Controller::ViewPaths.new)
  end

  def append_view_path(path)
    view_paths.push(*path)
  end

  def prepend_view_path(path)
    view_paths.unshift *path
  end

  # Return an array containing the names of public methods that have been marked hidden from the action processor.
  # By default, all methods defined in Engine::Controller::Base and included modules are hidden.
  # More methods can be hidden using <tt>hide_actions</tt>.
  def hidden_actions
    read_inheritable_attribute(:hidden_actions) || write_inheritable_attribute(:hidden_actions, [])
  end

  # Hide each of the given methods from being callable as actions.
  def hide_action(*names)
    write_inheritable_attribute(:hidden_actions, hidden_actions | names.map { |name| name.to_s })
  end
end
