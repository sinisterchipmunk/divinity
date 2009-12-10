begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "divinity"
    gem.summary = %Q{A new kind of game engine}
    gem.description = %Q{A new kind of game engine}
    gem.email = "sinisterchipmunk@gmail.com"
    gem.homepage = "http://github.com/sinisterchipmunk/divinity"
    gem.authors = ["Colin MacKenzie IV (sinisterchipmunk)"]
    gem.files.concat FileList["ext/**/*.c"].to_a
    gem.files.concat FileList["ext/**/*.h"].to_a
    gem.files.concat FileList["**/*.rb"].to_a
    gem.files.reject! { |i| i =~ /data\/cache/ }
    # dependencies
    gem.add_development_dependency "shoulda", ">= 0"
    gem.add_development_dependency "rake-compiler", ">= 0.7.0"
    gem.add_dependency "activesupport", ">= 2.3.4"
    gem.add_dependency "ruby-opengl", ">= 0.60.1"
    gem.add_dependency "rmagick", ">= 2.12.0"
    gem.add_dependency "log4r", ">= 1.1.2"
    gem.add_dependency "rubigen", ">= 1.5.2"
    # RubySDL is a tricky one
    gem.add_dependency((if RUBY_PLATFORM =~ /mingw32/ || RUBY_PLATFORM =~ /mswin32/
                          if RUBY_VERSION =~ /1\.8/ then "rubysdl-mswin32-1.8"  ## windows/ruby1.8
                          else                           "rubysdl-mswin32-1.9"  ## windows/ruby1.9
                          end
                        else                             "rubysdl"              ## *nix
                        end), ">= 2.1.0.1")
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
