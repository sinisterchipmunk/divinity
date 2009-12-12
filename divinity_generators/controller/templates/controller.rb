class <%=class_name%>Controller < ApplicationController
  <%actions.each do |action|%>
  def <%=action%>
  end
  <%end%>

  # The #update method fires between frames, every frame. You can use this to safely process application logic that
  # doesn't fit in any model.
  def update
    delta = params[:delta]            # the time differential in milliseconds between previous and current updates

    @framecount += 1
    @seconds_passed += delta
    if @seconds_passed > 1000         # update framerate every 1 second
      @framerate = @framecount
      @framecount = 0
      @seconds_passed = 0
    end
  end
end
