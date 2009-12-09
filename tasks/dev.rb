desc "Rakes gemspec and build, then reinstalls the gem"
task :reinstall do
  Rake::Task['gemspec'].invoke
  Rake::Task['build'].invoke
  `gem install --local pkg/divinity-0.0.0.gem --no-ri --no-rdoc`
end

desc "Removes rdoc and makes clean the C extensions"
task :clean do
  Rake::Task['clobber_doc']
  Dir["ext/**"].each do |fi|
    next unless File.directory?(fi)
    chdir(fi)
    `make clean`
    chdir(File.join(File.dirname(__FILE__), ".."))
  end
end

desc "Compiles C extensions"
task :compile do
  Dir["ext/**"].each do |fi|
    next unless File.directory?(fi)
    chdir(fi)
    `make`
    true
  end
end
