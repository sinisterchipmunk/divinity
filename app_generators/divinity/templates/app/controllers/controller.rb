class <%=module_name%>Controller < ApplicationController
  # The only action that fires every frame is the #update action. Each other action fires only once, when it is first
  # triggered. By default the #index action will fire when the engine is initialized.
  def index
    @total_rotation = 0
    @distance = 10
    @colors = [[1,0,0,1],             # red, green, blue, alpha
               [0,1,0,1],
               [0,0,1,1]]
    @framerate = 0
    @framecount = 0
    @seconds_passed = 0
  end

  # The #update method fires between frames, every frame. You can use this to safely process application logic that
  # doesn't fit in any model.
  def update
    delta = params[:delta]            # the time differential in milliseconds between previous and current updates

    seconds = (delta / 1000.0)        # convert delta to seconds
    speed   = 2*Math::PI              # Rotate 2PI radians per second
    @total_rotation += speed * seconds# update total rotation

    # find x and z to translate to (we won't move vertically this time)
    x, y, z = Math.cos(@total_rotation) * @distance, 0, Math.sin(@total_rotation) * @distance
    engine.translate_to! x, y, z

    # we want the camera to always be pointed at the squares
    engine.look_at 0, 0, -5

    @framecount += 1
    @seconds_passed += delta
    if @seconds_passed > 1000 # update framerate every 1 second
      @framerate = @framecount
      @framecount = 0
      @seconds_passed = 0
    end
  end
end
