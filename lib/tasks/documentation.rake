namespace :doc do
  desc "Generate documentation for the application. Set custom template with TEMPLATE=/path/to/rdoc/template.rb or title with TITLE=\"Custom Title\""
  Rake::RDocTask.new("app") { |rdoc|
    rdoc.rdoc_dir = 'doc/app'
    rdoc.template = ENV['template'] if ENV['template']
    rdoc.title    = ENV['title'] || "Divinity Application Documentation"
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.options << '--charset' << 'utf-8'
    rdoc.rdoc_files.include('doc/README_FOR_APP')
    rdoc.rdoc_files.include('app/**/*.rb')
    rdoc.rdoc_files.include('lib/**/*.rb')
  }

  desc "Generate documentation for the Divinity framework"
  Rake::RDocTask.new("divinity") { |rdoc|
    rdoc.rdoc_dir = 'doc/api'
    rdoc.template = "#{ENV['template']}.rb" if ENV['template']
    rdoc.title    = "Divinity Framework Documentation"
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.rdoc_files.include('README')
    rdoc.rdoc_files.include('vendor/divinity/divinity/CHANGELOG')
    rdoc.rdoc_files.include('vendor/divinity/divinity/MIT-LICENSE')
    rdoc.rdoc_files.include('vendor/divinity/divinity/README')
    rdoc.rdoc_files.include('vendor/divinity/divinity/lib/{*.rb,commands/*.rb,divinity_generator/*.rb}')
  }

  plugins = FileList['vendor/plugins/**'].collect { |plugin| File.basename(plugin) }

  desc "Generate documentation for all installed plugins"
  task :plugins => plugins.collect { |plugin| "doc:plugins:#{plugin}" }

  desc "Remove plugin documentation"
  task :clobber_plugins do
    rm_rf 'doc/plugins' rescue nil
  end

  #desc "Generate Divinity guides"
  #task :guides do
  #  require File.join(RAILTIES_PATH, "guides/divinity_guides")
  #  DivinityGuides::Generator.new(File.join(DIVINITY_ROOT, "doc/guides")).generate
  #end

  namespace :plugins do
    # Define doc tasks for each plugin
    plugins.each do |plugin|
      desc "Generate documentation for the #{plugin} plugin"
      task(plugin => :environment) do
        plugin_base   = "vendor/plugins/#{plugin}"
        options       = []
        files         = Rake::FileList.new
        options << "-o doc/plugins/#{plugin}"
        options << "--title '#{plugin.titlecase} Plugin Documentation'"
        options << '--line-numbers' << '--inline-source'
        options << '--charset' << 'utf-8'
        options << '-T html'

        files.include("#{plugin_base}/lib/**/*.rb")
        if File.exist?("#{plugin_base}/README")
          files.include("#{plugin_base}/README")
          options << "--main '#{plugin_base}/README'"
        end
        files.include("#{plugin_base}/CHANGELOG") if File.exist?("#{plugin_base}/CHANGELOG")

        options << files.to_s

        sh %(rdoc #{options * ' '})
      end
    end
  end
end
