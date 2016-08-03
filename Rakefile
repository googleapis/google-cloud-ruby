require "bundler/setup"

task :bundleupdate do
  gems.each do |gem|
    Dir.chdir gem do
      Bundler.with_clean_env do
        header "BUNDLE UPDATE FOR #{gem}"
        sh "bundle update"
      end
    end
  end
end

desc "Runs rubocop, jsodoc, and tests for all gems individually."
task :each, :bundleupdate do |t, args|
  bundleupdate = args[:bundleupdate]
  Rake::Task["bundleupdate"].invoke if bundleupdate
  gems.each do |gem|
    Dir.chdir gem do
      Bundler.with_clean_env do
        header "RUBOCOP, JSONDOC, TESTS FOR #{gem}"
        sh "bundle exec rake rubocop"
        sh "bundle exec rake jsondoc"
        sh "bundle exec rake test"
      end
    end
  end
end

desc "Runs tests for all gems."
task :test do
  gems.each do |gem|
    $LOAD_PATH.unshift "#{gem}/lib", "#{gem}/test"
    Dir.glob("#{gem}/test/**/*_test.rb").each { |file| require_relative file }
    $LOAD_PATH.delete "#{gem}/lib"
    $LOAD_PATH.delete "#{gem}/test"
  end
end

namespace :test do
  desc "Runs tests for all gems individually."
  task :each, :bundleupdate do |t, args|
    bundleupdate = args[:bundleupdate]
    Rake::Task["bundleupdate"].invoke if bundleupdate
    gems.each do |gem|
      Dir.chdir gem do
        Bundler.with_clean_env do
          header "RUNNING TESTS FOR #{gem}"
          sh "bundle exec rake test"
        end
      end
    end
  end

  desc "Runs tests with coverage for all gems."
  task :coverage do
    FileUtils.remove_dir "coverage", force: true
    FileUtils.mkdir "coverage"

    require "simplecov"
    SimpleCov.start do
      command_name :coverage
      track_files "lib/**/*.rb"
      add_filter "test/"
      gems.each { |gem| add_group gem, "#{gem}/lib" }
    end

    header "Running tests and coverage report"
    Rake::Task["test"].invoke
  end

  desc "Runs coveralls report for all gems."
  task :coveralls do
    require "simplecov"
    require "coveralls"
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter

    Rake::Task["test:coverage"].invoke
  end
end

desc "Runs acceptance tests for all gems."
task :acceptance, :project, :keyfile, :key do |t, args|
  project = args[:project] || ENV["GCLOUD_TEST_PROJECT"]
  keyfile = args[:keyfile] || ENV["GCLOUD_TEST_KEYFILE"]
  if project.nil? || keyfile.nil?
    fail "You must provide a project and keyfile. e.g. rake acceptance[test123, /path/to/keyfile.json] or GCLOUD_TEST_PROJECT=test123 GCLOUD_TEST_KEYFILE=/path/to/keyfile.json rake acceptance"
  end
  # always overwrite when running tests
  ENV["GOOGLE_CLOUD_PROJECT"] = project
  ENV["GOOGLE_CLOUD_KEYFILE"] = keyfile

  key = args[:key] || ENV["GCLOUD_TEST_KEY"]
  if key.nil?
    fail "You must provide an API KEY for translate acceptance tests."
  end  # always overwrite when running tests
  ENV["GOOGLE_CLOUD_KEY"] = key

  gems.each do |gem|
    $LOAD_PATH.unshift "#{gem}/lib", "#{gem}/acceptance"
    Dir.glob("#{gem}/acceptance/**/*_test.rb").each { |file| require_relative file }
    $LOAD_PATH.delete "#{gem}/lib"
    $LOAD_PATH.delete "#{gem}/acceptance"
  end
end

namespace :acceptance do
  desc "Runs acceptance tests for all gems individually."
  task :each, :bundleupdate do |t, args|
    bundleupdate = args[:bundleupdate]
    Rake::Task["bundleupdate"].invoke if bundleupdate
    gems.each do |gem|
      Dir.chdir gem do
        Bundler.with_clean_env do
          header "ACCEPTANCE TESTS FOR #{gem}"
          sh "bundle exec rake acceptance"
        end
      end
    end
  end

  desc "Runs acceptance tests with coverage for all gems."
  task :coverage do
    FileUtils.remove_dir "coverage", force: true
    FileUtils.mkdir "coverage"

    require "simplecov"
    SimpleCov.start do
      command_name :coverage
      track_files "lib/**/*.rb"
      add_filter "acceptance/"
      gems.each { |gem| add_group gem, "#{gem}/lib" }
    end

    header "Running acceptance tests and coverage report"
    Rake::Task["acceptance"].invoke
  end

  desc "Runs acceptance:cleanup for all gems."
  task :cleanup, :bundleupdate do |t, args|
    bundleupdate = args[:bundleupdate]
    Rake::Task["bundleupdate"].invoke if bundleupdate
    gems.each do |gem|
      cd gem do
        Bundler.with_clean_env do
          sh "bundle exec rake acceptance:cleanup"
        end
      end
    end
  end
end

desc "Runs rubocop report for all gems individually."
task :rubocop, :bundleupdate do |t, args|
  bundleupdate = args[:bundleupdate]
  Rake::Task["bundleupdate"].invoke if bundleupdate
  header "Running rubocop reports"
  gems.each do |gem|
    Dir.chdir gem do
      Bundler.with_clean_env do
        header "RUBOCOP REPORT FOR #{gem}"
        sh "bundle exec rake rubocop"
      end
    end
  end
end

desc "Runs jsondoc report for all gems individually."
task :jsondoc, :bundleupdate do |t, args|
  bundleupdate = args[:bundleupdate]
  Rake::Task["bundleupdate"].invoke if bundleupdate
  header "Running jsondoc reports"
  gems.each do |gem|
    Dir.chdir gem do
      Bundler.with_clean_env do
        header "JSONDOC FOR #{gem}"
        sh "bundle exec rake jsondoc"
      end
    end
  end
end

desc "Start an interactive shell."
task :console, :bundleupdate do |t, args|
  bundleupdate = args[:bundleupdate]
  Dir.chdir "google-cloud" do
    Bundler.with_clean_env do
      sh "bundle update" if bundleupdate
      sh "bundle exec rake console"
    end
  end
end

namespace :travis do
  desc "Runs acceptance tests for CI."
  task :acceptance do
    if ENV["TRAVIS_BRANCH"] == "master" &&
       ENV["TRAVIS_PULL_REQUEST"] == "false"
      header "Preparing to run acceptance tests"
      # Decrypt the keyfile
      `openssl aes-256-cbc -K $encrypted_629ec55f39b2_key -iv $encrypted_629ec55f39b2_iv -in keyfile.json.enc -out keyfile.json -d`

      Rake::Task["acceptance"].invoke
    else
      header "Skipping acceptance tests"
    end
  end
end

def gems
  `git ls-files -- */*.gemspec`.split("\n").map { |gem| gem.split("/").first }.sort
end

def header str
  line_length = str.length + 8
  puts ""
  puts "#" * line_length
  puts "### #{str} ###"
  puts "#" * line_length
  puts ""
end

task :default => :test
