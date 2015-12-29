require "bundler/gem_tasks"
require "rake/testtask"
require "gcloud/jsondoc"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

desc "Generates JSON output from gcloud-ruby .yardoc"
task :gcloud do
  registry = YARD::Registry.load! "../gcloud-ruby/.yardoc"
  builder = Gcloud::Jsondoc.new registry
  json = builder.docs.target!
  File.open("docs/examples/gcloud-docs.json", 'w'){|f| f.write json}
end
