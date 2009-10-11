module Engine::DefaultRenderBlock
  def add_default_render_block
    during_render do
      glClear(clear_on_render) if clear_on_render != 0
      glLoadIdentity()
      frame_manager.render
    end
  end
end