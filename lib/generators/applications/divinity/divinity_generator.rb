class DivinityGenerator < Rails::Generator::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = args.shift
    @app_name = File.basename(File.expand_path(@destination_root))
  end

  def manifest
    record do |m|
      create_directories(m)
      create_interfaces(m)
      create_resources(m)
    end
  end

  def after_generate
  end

  protected
  def banner
    "Usage: #{$0} /path/to/your/app [options]"
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("-r", "--ruby=path", String,
           "Path to the Ruby binary of your choice (otherwise scripts use env).",
           "Default: #{DEFAULT_SHEBANG}") { |v| options[:shebang] = v }
    opt.on("-f", "--freeze", "Freeze Divinity in vendor/divinity from the gems generating the skeleton",
           "Default: false") { |v| options[:freeze] = v }
  end

  private
  def create_directories(m)

  end

  def create_interfaces(m)

  end

  def create_resources(m)

  end
end