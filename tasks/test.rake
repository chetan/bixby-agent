
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
end

task :default => :test

begin
  require 'single_test'
  SingleTest.load_tasks

rescue LoadError
  warn "single_test not available"
end
