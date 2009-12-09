require 'rake/testtask'
namespace :test do
  desc 'Run all unit tests'
  Rake::TestTask.new(:unit => :check_dependencies) do |t|
    t.libs << "lib"
    t.libs << "test"
    t.test_files = "test/unit/**/*.rb"
    t.verbose = true
  end

  desc 'Run all tests'
  task :all do |t|
    Rake::Task['test:unit'].invoke
  end
end

task :test => "test:all"
task :default => "test:all"