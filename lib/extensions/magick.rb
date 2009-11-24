module Magick
  def self.enumeration_for(key, value)
    case key
      when 'font_stretch' then "Magick::#{value.camelize}Type".constantize
      else value
    end
  end
end