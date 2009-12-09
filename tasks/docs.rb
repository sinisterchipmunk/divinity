require 'rake/rdoctask'
desc 'Generate documentation'
Rake::RDocTask.new(:doc) do |t|
  t.rdoc_dir = "doc"
  t.title = 'DivinityEngine'
  t.options << '--line-numbers' << '--inline-source'
  t.rdoc_files.include 'README*', 'TODO*', 'LICENSE'
  #t.rdoc_files.include 'divinity_engine.rb'
  #t.rdoc_files.include 'dependencies.rb'
  t.rdoc_files.include 'lib/**/*.rb'
  accessors = { :delegate => "delegate" }
  t.options << "--accessor" << accessors.collect { |a| "#{a[0]}=#{a[1]}" }.join(",")
end
