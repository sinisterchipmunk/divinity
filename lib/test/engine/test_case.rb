class Test::Engine::TestCase < Test::Unit::TestCase
  attr_reader :engine, :time

  # Sets the timeout if given; returns the timeout regardless. Defaults to 1 second.
  def timeout(time = nil); self.class.timeout(time); end

  # Sets the timeout if given; returns the timeout regardless. Defaults to 1 second.
  def self.timeout(time = nil)
    @timeout ||= 1.0
    @timeout = time if time
    @timeout
  end

  # Sets the controller to the one named. If action is not specified, it defaults to 'index', although if the engine
  # hasn't been started yet, this can be changed to another action before it fires. The options hash can contain any
  # parameters to send as part of the request.
  def controller(name, action = nil, options = {})
    action, options = nil, options.merge(action) if action.kind_of? Hash
    action = 'index' if action.nil? and @engine.find_controller(name).action_methods.include? 'index'
    @engine.assume_controller(name, action, options)
  end

  # Sets the action to the one named. This takes place immediately if the engine is already running, or it takes place
  # when the engine is started if it's currently stopped or paused. The options hash can contain any parameters to send
  # as part of the request.
  def action(name, options = {})
    @engine.assume_controller(@engine.current_controller.controller_name, name, options)
  end

  def setup_engine
    @engine = DivinityEngine.new(:width => 800, :height => 600, :fullscreen => false)
    @time = 0

    @engine.before_update do |ticks|
      # convert ticks to seconds and add it to timer; stop the engine if timer > timeout
      @time += (ticks / 1000.0)
      @engine.stop! if time > timeout
      __send__(@method_name)
    end
  end

  def self.inherited(base) #:nodoc:
    # don't want our shut-it-up test to be repeated for the test cases
    base.class_eval do
      undef test_engine_completed_initialization?
    end
  end

  def teardown_engine
    Divinity.system_logger.debug "! TEST COMPLETE\n"
    engine.stop! if engine
  end

  def test_engine_completed_initialization?
    assert engine.initialized?
  end

  def run(result) #:nodoc:
    yield(STARTED, name)
    @_result = result
    setup_engine
    begin
      setup
      # basically just to shut up the unit test, because it'll raise a false failure if we don't test something
      if @method_name == "test_engine_completed_initialization?"
        __send__(@method_name)
      else
        engine.go!
      end
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
