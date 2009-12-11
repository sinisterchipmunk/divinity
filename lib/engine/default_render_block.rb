module Engine::DefaultRenderBlock
  def add_default_render_block
    before_render do
      glClear(clear_on_render) if clear_on_render != 0
      glLoadIdentity()
    end

    during_render do
      if @controller && @controller.response.view
        @controller.response.view.process
      end
    end
  end
end
