require 'divinity_engine'

module Divinity
  logfile = File.join(DIVINITY_ROOT, "divinity.log")
  @@logger = Log4r::Logger.new("divinity")
  @@logger.outputters = Log4r::FileOutputter.new(logfile, :filename => logfile)

  def self.logger
    @@logger
  end
end
