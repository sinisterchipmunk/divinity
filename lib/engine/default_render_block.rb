module Engine::DefaultRenderBlock
  def add_default_render_block
    before_render do
      glClear(clear_on_render) if clear_on_render != 0
      glLoadIdentity()
    end
  end
end
