namespace :divinity do
  namespace :freeze do
    desc "Lock this application to the current gems (by unpacking them into vendor/divinity)"
    task :gems do
      deps = %w(actionpack activerecord actionmailer activesupport activeresource)
      require 'rubygems'
      require 'rubygems/gem_runner'

      divinity = (version = ENV['VERSION']) ?
        Gem.cache.find_name('divinity', "= #{version}").first :
        Gem.cache.find_name('divinity').sort_by { |g| g.version }.last

      version ||= divinity.version

      unless divinity
        puts "No divinity gem #{version} is installed.  Do 'gem list divinity' to see what you have available."
        exit
      end

      puts "Freezing to the gems for Divinity #{divinity.version}"
      rm_rf   "vendor/divinity"
      mkdir_p "vendor/divinity"

      begin
        chdir("vendor/divinity") do
          divinity.dependencies.select { |g| deps.include? g.name }.each do |g|
            Gem::GemRunner.new.run(["unpack", g.name, "--version", g.version_requirements.to_s])
            mv(Dir.glob("#{g.name}*").first, g.name)
          end

          Gem::GemRunner.new.run(["unpack", "divinity", "--version", "=#{version}"])
          FileUtils.mv(Dir.glob("divinity*").first, "divinity")
        end
      rescue Exception
        rm_rf "vendor/divinity"
        raise
      end
    end

#    desc 'Lock to latest Edge Divinity, for a specific release use RELEASE=1.2.0'
#    task :edge do
#      require 'open-uri'
#      version = ENV["RELEASE"] || "edge"
#      target  = "divinity_#{version}.zip"
#      commits = "http://github.com/api/v1/yaml/divinity/divinity/commits/master"
#      url     = "http://dev.rubyondivinity.org/archives/#{target}"
#
#      chdir 'vendor' do
#        latest_revision = YAML.load(open(commits))["commits"].first["id"]
#
#        puts "Downloading Divinity from #{url}"
#        File.open('divinity.zip', 'wb') do |dst|
#          open url do |src|
#            while chunk = src.read(4096)
#              dst << chunk
#            end
#          end
#        end
#
#        puts 'Unpacking Divinity'
#        rm_rf 'divinity'
#        `unzip divinity.zip`
#        %w(divinity.zip divinity/Rakefile divinity/cleanlogs.sh divinity/pushgems.rb divinity/release.rb).each do |goner|
#          rm_f goner
#        end
#
#        touch "divinity/REVISION_#{latest_revision}"
#      end
#
#      puts 'Updating current scripts, javascripts, and configuration settings'
#      Rake::Task['divinity:update'].invoke
#    end
  end

  desc "Unlock this application from freeze of gems or edge and return to a fluid use of system gems"
  task :unfreeze do
    rm_rf "vendor/divinity"
  end

  desc "Update both configs, scripts and public/javascripts from Divinity"
  task :update => [ "update:scripts", "update:javascripts", "update:configs", "update:application_controller" ]

  desc "Applies the template supplied by LOCATION=/path/to/template"
  task :template do
    require 'divinity_generator/generators/applications/app/template_runner'
    Divinity::TemplateRunner.new(ENV["LOCATION"])
  end

  namespace :update do
    desc "Add new scripts to the application script/ directory"
    task :scripts do
      local_base = "script"
      edge_base  = "#{File.dirname(__FILE__)}/../../bin"

      local = Dir["#{local_base}/**/*"].reject { |path| File.directory?(path) }
      edge  = Dir["#{edge_base}/**/*"].reject { |path| File.directory?(path) }
  
      edge.each do |script|
        base_name = script[(edge_base.length+1)..-1]
        next if base_name == "divinity"
        next if local.detect { |path| base_name == path[(local_base.length+1)..-1] }
        if !File.directory?("#{local_base}/#{File.dirname(base_name)}")
          mkdir_p "#{local_base}/#{File.dirname(base_name)}"
        end
        install script, "#{local_base}/#{base_name}", :mode => 0755
      end
    end

#    desc "Update config/boot.rb from your current divinity install"
#    task :configs do
#      require 'railties_path'
#      FileUtils.cp(RAILTIES_PATH + '/environments/boot.rb', DIVINITY_ROOT + '/config/boot.rb')
#    end
    
    desc "Rename application.rb to application_controller.rb"
    task :application_controller do
      old_style = DIVINITY_ROOT + '/app/controllers/application.rb'
      new_style = DIVINITY_ROOT + '/app/controllers/application_controller.rb'
      if File.exists?(old_style) && !File.exists?(new_style)
        FileUtils.mv(old_style, new_style)
        puts "#{old_style} has been renamed to #{new_style}, update your SCM as necessary"
      end
    end
#
#    desc "Generate dispatcher files in DIVINITY_ROOT/public"
#    task :generate_dispatchers do
#      require 'railties_path'
#      FileUtils.cp(RAILTIES_PATH + '/dispatches/config.ru', DIVINITY_ROOT + '/config.ru')
#      FileUtils.cp(RAILTIES_PATH + '/dispatches/dispatch.fcgi', DIVINITY_ROOT + '/public/dispatch.fcgi')
#      FileUtils.cp(RAILTIES_PATH + '/dispatches/dispatch.rb', DIVINITY_ROOT + '/public/dispatch.rb')
#      FileUtils.cp(RAILTIES_PATH + '/dispatches/dispatch.rb', DIVINITY_ROOT + '/public/dispatch.cgi')
#    end
  end
end
