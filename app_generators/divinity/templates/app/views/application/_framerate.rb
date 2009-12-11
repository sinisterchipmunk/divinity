glColor4f(1,1,1,1)     # white
glEnable GL_TEXTURE_2D # the font is texture-mapped

# I18n works! You can edit translations in config/locales/*.yml
engine.write(:right, :bottom, "#{I18n.translate(:frames_per_second).titleize}: #{@framerate}")
