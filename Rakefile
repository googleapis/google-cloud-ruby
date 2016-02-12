require "bundler/gem_tasks"
require "rake/testtask"
require "gcloud/jsondoc"
require "pathname"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

desc "Generates JSON output from gcloud-ruby .yardoc"
task :gcloud do
  puts "If no output follows, verify data at: ../gcloud-ruby/.yardoc"
  registry = YARD::Registry.load! "../gcloud-ruby/.yardoc"
  generator = Gcloud::Jsondoc::Generator.new registry
  FileUtils.mkdir_p "json"
  generator.docs.each do |doc|
    json = doc.jbuilder.target!
    json_path = "json/master/"
    json_path += doc.filepath
    dirname = Pathname.new(json_path).dirname
    puts json_path
    FileUtils.mkdir_p(dirname)
    File.write json_path, json
  end
end
