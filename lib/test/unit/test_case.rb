class Test::Unit::TestCase
  alias _add_failure add_failure
  alias _add_error   add_error

  def add_failure(message, backtrace)
    Divinity.system_logger.warn message
    Divinity.system_logger.warn backtrace.first
    _add_failure(message, backtrace)
  end

  def add_error(err)
    Divinity.system_logger.error err.message
    Divinity.system_logger.error err.backtrace.first
    _add_error(err)
  end
end
