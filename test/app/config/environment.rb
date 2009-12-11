# Specifies gem version of Divinity to use when vendor/divinity is not present
DIVINITY_GEM_VERSION = '0.0.0' unless defined? DIVINITY_GEM_VERSION

# Bootstrap the Divinity environment, frameworks, and configuration
require File.join(File.dirname(__FILE__), 'boot')

Divinity::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{DIVINITY_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the modules named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.modules = [ :divinity, :all ]

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Divinity.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end
