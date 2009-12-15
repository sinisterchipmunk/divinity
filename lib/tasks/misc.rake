task :default => :test
task :environment do
  $divinity_rake_task = true
  require(File.join(DIVINITY_ROOT, 'config', 'environment'))
end

task :divinity_env do
  unless defined? DIVINITY_ENV
    DIVINITY_ENV = ENV['DIVINITY_ENV'] ||= 'development'
  end
end
