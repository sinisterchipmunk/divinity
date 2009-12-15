$VERBOSE = nil

# Load Divinity rakefile extensions
Dir["#{File.dirname(__FILE__)}/*.rake"].each { |ext| load ext }

# Load any custom rakefile extensions
Dir["#{DIVINITY_ROOT}/vendor/plugins/*/**/tasks/**/*.rake"].sort.each { |ext| load ext }
Dir["#{DIVINITY_ROOT}/lib/tasks/**/*.rake"].sort.each { |ext| load ext }
