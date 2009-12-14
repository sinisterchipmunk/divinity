class InterfaceGenerator < RubiGen::Base

  default_options :author => nil

  attr_reader :name, :file_name, :class_name, :actions
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
    @actions = %w(index mouse_pressed mouse_released mouse_clicked mouse_moved mouse_dragged key_pressed key_released
                  key_typed)
    #@actions = args.dup
    @file_name = @name.underscore
    @class_name = @name.camelize
    extract_options
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory 'app/controllers/interfaces'
      m.directory 'app/helpers/interfaces'
      m.directory "app/views/interfaces/#{file_name}"
      m.directory 'test/functional/interfaces'

      # Create stubs
      m.template 'app/controller.rb', "app/controllers/interfaces/#{file_name}_controller.rb"
      m.template 'app/helper.rb',     "app/helpers/interfaces/#{file_name}_helper.rb"
      actions.each do |action|
        m.template 'app/view.rb',       "app/views/interfaces/#{file_name}/#{action}.rb",
                   :assigns => { :action => action }
      end
    end
  end

  protected
    def banner
      <<-EOS
Creates a user interface for the Divinity engine

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