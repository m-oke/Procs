require 'bundler/gem_tasks'

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/**/*.rb"
  t.verbose = true
end

desc "Analyze code duplication"
task :flay do
  system "flay lib/**/*.rb"
end

desc "Analyze code complexity"
task :flog do
  system "find lib -name \*.rb | xargs flog"
end

task :default => :test
