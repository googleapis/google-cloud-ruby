require "bundler/setup"
require "bundler/gem_tasks"

require "rubocop/rake_task"
RuboCop::RakeTask.new

require "rake/testtask"
desc "Run tests."
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = false
end

namespace :test do
  desc "Run tests with coverage."
  task :coverage do
    require "simplecov"
    SimpleCov.start do
      command_name "google-cloud-storage"
      track_files "lib/**/*.rb"
      add_filter "test/"
    end

    Rake::Task[:test].invoke
  end
end

# Acceptance tests
desc "Run the storage acceptance tests."
task :acceptance, :project, :keyfile do |t, args|
  project = args[:project]
  project ||= ENV["STORAGE_TEST_PROJECT"] || ENV["GCLOUD_TEST_PROJECT"]
  keyfile = args[:keyfile]
  keyfile ||= ENV["STORAGE_TEST_KEYFILE"] || ENV["GCLOUD_TEST_KEYFILE"]
  if keyfile
    keyfile = File.read keyfile
  else
    keyfile ||= ENV["STORAGE_TEST_KEYFILE_JSON"] || ENV["GCLOUD_TEST_KEYFILE_JSON"]
  end
  if project.nil? || keyfile.nil?
    fail "You must provide a project and keyfile. e.g. rake acceptance[test123, /path/to/keyfile.json] or STORAGE_TEST_PROJECT=test123 STORAGE_TEST_KEYFILE=/path/to/keyfile.json rake acceptance"
  end
  # clear any env var already set
  require "google/cloud/storage/credentials"
  (Google::Cloud::Storage::Credentials::PATH_ENV_VARS +
   Google::Cloud::Storage::Credentials::JSON_ENV_VARS).each do |path|
    ENV[path] = nil
  end
  require "google/cloud/pubsub/credentials"
  (Google::Cloud::Pubsub::Credentials::PATH_ENV_VARS +
   Google::Cloud::Pubsub::Credentials::JSON_ENV_VARS).each do |path|
    ENV[path] = nil
  end
  # always overwrite when running tests
  ENV["STORAGE_PROJECT"] = project
  ENV["STORAGE_KEYFILE_JSON"] = keyfile
  ENV["PUBSUB_PROJECT"] = project
  ENV["PUBSUB_KEYFILE_JSON"] = keyfile

  Rake::Task["acceptance:run"].invoke
end

namespace :acceptance do
  desc "Run tests with coverage."
  task :coverage, :project, :keyfile do |t, args|
    require "simplecov"
    SimpleCov.start do
      command_name "google-cloud-storage"
      track_files "lib/**/*.rb"
      add_filter "acceptance/"
    end

    Rake::Task[:acceptance].invoke
  end

  desc "Removes *ALL* buckets and files. Use with caution."
  task :cleanup do |t, args|
    project = args[:project]
    project ||= ENV["STORAGE_TEST_PROJECT"] || ENV["GCLOUD_TEST_PROJECT"]
    keyfile = args[:keyfile]
    keyfile ||= ENV["STORAGE_TEST_KEYFILE"] || ENV["GCLOUD_TEST_KEYFILE"]
    if keyfile
      keyfile = File.read keyfile
    else
      keyfile ||= ENV["STORAGE_TEST_KEYFILE_JSON"] || ENV["GCLOUD_TEST_KEYFILE_JSON"]
    end
    if project.nil? || keyfile.nil?
      fail "You must provide a project and keyfile. e.g. rake acceptance:cleanup[test123, /path/to/keyfile.json] or STORAGE_TEST_PROJECT=test123 STORAGE_TEST_KEYFILE=/path/to/keyfile.json rake acceptance:cleanup"
    end
    # clear any env var already set
    require "google/cloud/storage/credentials"
    (Google::Cloud::Storage::Credentials::PATH_ENV_VARS +
     Google::Cloud::Storage::Credentials::JSON_ENV_VARS).each do |path|
      ENV[path] = nil
    end
    # always overwrite when running tests
    ENV["STORAGE_PROJECT"] = project
    ENV["STORAGE_KEYFILE_JSON"] = keyfile

    $LOAD_PATH.unshift "lib"
    require "google/cloud/storage"
    puts "Cleaning up Storage buckets and files"
    Google::Cloud.storage.buckets.all do |b|
      begin
        b.retention_period = nil if b.retention_period
        b.files(versions: true).all do |file|
          file.release_temporary_hold! if file.temporary_hold?
          file.release_event_based_hold! if file.event_based_hold?
          file.delete generation: true
        end
        # Add one second delay between bucket deletes to avoid rate limiting errors
        sleep 1
        b.delete
      rescue => e
        puts "Error while cleaning up bucket #{b.name}\n\n#{e}"
      end
    end
  end

  Rake::TestTask.new :run do |t|
    t.libs << "acceptance"
    t.test_files = FileList["acceptance/**/*_test.rb"]
    t.warning = false
  end
end

desc "Run yard-doctest example tests."
task :doctest do
  sh "bundle exec yard config load_plugins true && bundle exec yard doctest"
end

desc "Start an interactive shell."
task :console do
  require "irb"
  require "irb/completion"
  require "pp"

  $LOAD_PATH.unshift "lib"

  require "google-cloud-storage"
  def gcloud; @gcloud ||= Google::Cloud.new; end

  ARGV.clear
  IRB.start
end

require "yard"
require "yard/rake/yardoc_task"
YARD::Rake::YardocTask.new do |y|
  y.options << "--fail-on-warning"
end

desc "Run the CI build"
task :ci do
  header "BUILDING google-cloud-storage"
  header "google-cloud-storage rubocop", "*"
  Rake::Task[:rubocop].invoke
  header "google-cloud-storage yard", "*"
  Rake::Task[:yard].invoke
  header "google-cloud-storage doctest", "*"
  Rake::Task[:doctest].invoke
  header "google-cloud-storage test", "*"
  Rake::Task[:test].invoke
end
namespace :ci do
  desc "Run the CI build, with acceptance tests."
  task :acceptance do
    Rake::Task[:ci].invoke
    header "google-cloud-storage acceptance", "*"
    Rake::Task[:acceptance].invoke
  end
  task :a do
    # This is a handy shortcut to save typing
    Rake::Task["ci:acceptance"].invoke
  end
end

task :default => :test

def header str, token = "#"
  line_length = str.length + 8
  puts ""
  puts token * line_length
  puts "#{token * 3} #{str} #{token * 3}"
  puts token * line_length
  puts ""
end
