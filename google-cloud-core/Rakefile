require "bundler/gem_tasks"

require "rake/testtask"
Rake::TestTask.new(:test) do |test|
  test.warning = true
  test.libs << "test"
  test.pattern = "test/**/*_test.rb"
end

task :default => :test
