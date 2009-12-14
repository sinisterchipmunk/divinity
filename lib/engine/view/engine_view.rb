class Engine::View::EngineView < Engine::View::Base
  def process
    super(:layout => false)
  end

  private
    #def load
    #  return @content if @loaded_path == @path
    #  @loaded_path = @path
    #  @content = File.read(@path)
    #end
end
