class ContentModuleGenerator < RubiGen::Base

  default_options :author => nil

  attr_reader :name, :base

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
    @base = "vendor/mods/#{name}"
    extract_options
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory "#{base}/actors"

      # Create stubs
      m.template 'resource_map.yml', "#{base}/resource_map.yml"
      m.template 'actors/joe.rb',    "#{base}/actors/joe.rb"
    end
  end

  protected
    def banner
      <<-EOS
Creates a Content Module with the specified name in vendor/mods/[name] which
you can then use to add modular content to your game. Each project also loads
the content found in resources/*, so use this for content that won't
necessarily be bundled with the main game (usually for downloadable content).

USAGE: #{$0} #{spec.name} name
EOS
    end

    def add_options!(opts)
      # opts.separator ''
      # opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |o| options[:author] = o }
      # opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end
end