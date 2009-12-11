module Divinity
  class BacktraceCleaner < ActiveSupport::BacktraceCleaner
    ERB_METHOD_SIG = /:in `_run_erb_.*/

    DIVINITY_GEMS   = %w( activesupport opengl RMagick log4r rubigen sdl divinity )

    VENDOR_DIRS  = %w( vendor/divinity )
    SERVER_DIRS  = %w(  )
    DIVINITY_NOISE  = %w( script/server )
    RUBY_NOISE   = %w( rubygems/custom_require benchmark.rb )

    ALL_NOISE    = VENDOR_DIRS + SERVER_DIRS + DIVINITY_NOISE + RUBY_NOISE

    def initialize
      super
      add_filter   { |line| line.sub("#{DIVINITY_ROOT}/", '') }
      add_filter   { |line| line.sub(ERB_METHOD_SIG, '') }
      add_filter   { |line| line.sub('./', '/') } # for tests

      add_gem_filters

      add_silencer { |line| ALL_NOISE.any? { |dir| line.include?(dir) } }
      add_silencer { |line| DIVINITY_GEMS.any? { |gem| line =~ /^#{gem} / } }
      add_silencer { |line| line =~ %r(vendor/plugins/[^\/]+/lib) }
    end
    
    
    private
      def add_gem_filters
        Gem.path.each do |path|
          # http://gist.github.com/30430
          add_filter { |line| line.sub(/(#{path})\/gems\/([a-z]+)-([0-9.]+)\/(.*)/, '\2 (\3) \4')}
        end

        vendor_gems_path = Divinity::GemDependency.unpacked_path.sub("#{DIVINITY_ROOT}/",'')
        add_filter { |line| line.sub(/(#{vendor_gems_path})\/([a-z]+)-([0-9.]+)\/(.*)/, '\2 (\3) [v] \4')}
      end
  end

  # For installing the BacktraceCleaner in the test/unit
  module BacktraceFilterForTestUnit #:nodoc:
    def self.included(klass)
      klass.send :alias_method_chain, :filter_backtrace, :cleaning
    end

    def filter_backtrace_with_cleaning(backtrace, prefix=nil)
      backtrace = filter_backtrace_without_cleaning(backtrace, prefix)
      backtrace = backtrace.first.split("\n") if backtrace.size == 1
      Divinity.backtrace_cleaner.clean(backtrace)
    end
  end
end
