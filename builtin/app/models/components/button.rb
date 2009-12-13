class Components::Button
  attr_accessor :state
  attr_accessor :caption

  # An arbitrary "action" that can be associated with this Button. It doesn't really do anything except
  # make it easier to check which button you're working with without having to check the caption. The
  # default value is equal to whatever the #caption is, except that it's underscored (ie "Single Player"
  # becomes "single_player").
  #
  # Actually, any value can be assigned to the action. For instance, an action could be a proc so that
  # you can pass around a small set of instructions. Of course, you need to call that proc manually.
  #
  attr_accessor :action

  def initialize(caption = "Untitled", action = caption.underscore.tr(' ', '_'))
    @caption = caption
    @action = action
  end
end
