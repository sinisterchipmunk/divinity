DIVINITY_ENV = (ENV['DIVINITY_ENV'] || 'development').dup unless defined?(DIVINITY_ENV)

unless defined? DIVINITY_FRAMEWORK_ROOT
  DIVINITY_FRAMEWORK_ROOT = File.expand_path(ENV['DIVINITY_FRAMEWORK_ROOT'] || File.join(File.dirname(__FILE__), ".."))
end

#require 'divinity_engine'

module Divinity
  class << self
    # The Configuration instance used to configure the Divinity environment
    def configuration
      @@configuration
    end

    def configuration=(configuration)
      @@configuration = configuration
    end

    def initialized?
      @initialized || false
    end

    def initialized=(initialized)
      @initialized = true
    end

    def logger
      if defined?(DIVINITY_DEFAULT_LOGGER)
        DIVINITY_DEFAULT_LOGGER
      else
        nil
      end
    end

    def engine_logger
      if defined?(DIVINITY_ENGINE_LOGGER)
        DIVINITY_ENGINE_LOGGER
      else
        nil
      end
    end

    def system_logger
      if defined?(DIVINITY_SYSTEM_LOGGER)
        DIVINITY_SYSTEM_LOGGER
      else
        nil
      end
    end

    def backtrace_cleaner
      @@backtrace_cleaner ||= begin
        require 'divinity/backtrace_cleaner'
        Divinity::BacktraceCleaner.new
      end
    end

    def root
      Pathname.new(DIVINITY_ROOT) if defined?(DIVINITY_ROOT)
    end

    def env
      @_env ||= ActiveSupport::StringInquirer.new(DIVINITY_ENV)
    end

    def cache
      DIVINITY_CACHE
    end

    def version
      VERSION::STRING
    end
  end

#  unless defined?(DIVINITY_DEFAULT_LOGGER)
#    log_path = File.directory?(File.join(DIVINITY_ROOT, "log")) ? File.join(DIVINITY_ROOT, "log") : DIVINITY_ROOT
#    log_file = File.join(log_path, "divinity.log")
#    DIVINITY_DEFAULT_LOGGER = Log4r::Logger.new("divinity")
#    DIVINITY_DEFAULT_LOGGER.outputters = Log4r::FileOutputter.new(log_file, :filename => log_file)
#  end
end
