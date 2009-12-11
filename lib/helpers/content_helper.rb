# Helper to provide methods to make loading data for Engine::ContentModule's more intuitive.
#
module Helpers::ContentHelper
  # Returns an image loaded from the plugin's base_path, unless path is an absolute one
  def image(path)
    # if path exists, is a Unix-style absolute, or is a Windows-style absolute, then use it as is.
    unless File.file?(path) or path[0] == ?/ or path[1] == ?:
      # else, tack base_path to the front of it
      path = File.join(base_path, path)
    end
    Resources::Image.new(path)
  end
end