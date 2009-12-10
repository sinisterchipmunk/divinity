class Test::Engine::TestCase < Test::Unit::TestCase
  attr_reader :engine, :time

  # Sets the timeout if given; returns the timeout regardless. Defaults to 5 seconds.
  def timeout(time = nil); self.class.timeout(time); end

  # Sets the timeout if given; returns the timeout regardless. Defaults to 5 seconds.
  def self.timeout(time = nil)
    @timeout ||= 5.0
    @timeout = time if time
    @timeout
  end

  def setup_engine
    @engine = DivinityEngine.new(:dry_run => true)
    @time = 0
    @engine.during_update do |ticks|
      # convert ticks to seconds and add it to timer; stop the engine if timer > timeout
      @time += (ticks / 1000.0)
      puts @time
      @engine.stop! if time > timeout
      __send__(@method_name)
    end
  end

  def teardown_engine
    engine.stop! if engine
  end

  def run(result) #:nodoc:
    yield(STARTED, name)
    @_result = result
    setup_engine
    begin
      setup
      engine.go!
    rescue Test::Unit::AssertionFailedError => e
      add_failure(e.message, e.backtrace)
    rescue Exception
      raise if PASSTHROUGH_EXCEPTIONS.include? $!.class
      add_error($!)
    ensure
      begin
        teardown
      rescue AssertionFailedError => e
        add_failure(e.message, e.backtrace)
      rescue Exception
        raise if PASSTHROUGH_EXCEPTIONS.include? $!.class
        add_error($!)
      end
      teardown_engine
    end
    result.add_run
    yield(FINISHED, name)
  end
end