module Engine::Controller::ClassMethods
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
