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
      m.directory "app/models"
      m.directory "resources/#{name.pluralize.underscore}"
      m.directory "test/unit"
      #m.directory "test/fixtures"

      # Create stubs
      m.template "model.rb",     "app/models/#{file_name}.rb"
      m.template "unit_test.rb", "test/unit/#{file_name}.rb"
      #m.template "fixture.yml",  "test/fixtures/#{file_name}.yml"
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