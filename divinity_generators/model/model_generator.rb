class ModelGenerator < RubiGen::Base

  default_options :author => nil

  attr_reader :name, :class_name, :file_name, :plural_name, :attributes

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
    @class_name  = @name.camelize
    @file_name   = @name.underscore
    @plural_name = @name.pluralize
    @attributes  = args.dup
    extract_options
  end

  def manifest
    record do |m|
      raise "Not implemented yet"
      # Ensure appropriate folder(s) exists
      #m.directory 'some_folder'

      # Create stubs

      # m.template           "template.rb.erb", "some_file_after_erb.rb"
      # m.template_copy_each ["template.rb", "template2.rb"]
      # m.template_copy_each ["template.rb", "template2.rb"], "some/path"
      # m.file           "file", "some_file_copied"
      # m.file_copy_each ["path/to/file", "path/to/file2"]
      # m.file_copy_each ["path/to/file", "path/to/file2"], "some/path"
    end
  end

  protected
    def banner
      <<-EOS
Creates a model (resource) with the specified name and attributes.

USAGE: #{$0} #{spec.name} name [attribute1 attribute2]
EXAMPLE: #{$0} #{spec.name} actor sex intelligence constitution dexterity ...
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