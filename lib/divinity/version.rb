module Divinity
  class VERSION
    unless defined? STRING
      STRING = File.read(File.join(File.dirname(__FILE__), "../../VERSION")).chomp
      MAJOR, MINOR, TINY = STRING.split(/\./).collect { |i| i.to_i }
    end
  end
end
