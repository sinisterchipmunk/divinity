class ControllerGenerator < RubiGen::Base

  default_options :author => nil

  attr_reader :name, :file_name, :class_name, :actions

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
    @file_name = @name.underscore
    @class_name = @name.camelize
    extract_options
    @actions = args
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory 'app/controllers'
      m.directory 'app/helpers'
      m.directory "app/views/#{file_name}"
      m.directory 'test/functional'

      # Create stubs
      m.template "controller.rb", "app/controllers/#{file_name}_controller.rb"
      m.template "helper.rb", "app/helpers/#{file_name}_helper.rb"
      m.template "functional_test.rb", "test/functional/#{file_name}_test.rb"
      m.template "_framerate.rb", "app/views/#{file_name}/_framerate.rb"
      actions.each do |action|
        m.template "view.rb", "app/views/#{file_name}/#{action}.rb", :assigns => { :action => action }
      end
    end
  end

  protected
    def banner
      <<-EOS
Creates a Divinity Engine controller. Engine controllers are the highest level
of your application.

USAGE: #{$0} #{spec.name} controller_name [action1 action2]
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
