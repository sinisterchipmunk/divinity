# This module is included to Engine::View::Base by default and generates helper methods to assist with adding and laying
# out components. It searches the Components namespace for all inheritors of Components::ComponentController, generating
# the helper methods automatically. That way, each usage is identical for all components unless it is explicitly
# overridden elsewhere.
#
module Helpers::ComponentHelper
  # this method is not actually used. it is here for me to model other methods after. FIXME: delete this method when
  # a meta copy has been finished.
  #
  # usage example:
  #   button :north, "Hello World"
  #   template :north, "Hello World"
  #
  def template(*args, &block)
    # First we need to see what the layout is expecting. The first X arguments will be sent there. The first argument
    # of the "add" method for any layout is the component itself, so we'll subtract that from the number of other
    # arguments required.
    x = @layout.method(:add).arity - 1
    layout_arguments = args.slice!(0, x)

    # all of the remaining arguments will be passed into the component in the form of a Request when it is instantiated.
    request = Engine::Controller::Request.new(*args, &block)

    # now to instantiate the component and add it to the layout.
    comp = Components::ButtonController.new(engine, request)
  end
end
