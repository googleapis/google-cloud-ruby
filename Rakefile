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
  if keyfile
    keyfile = File.read keyfile
  else
    keyfile ||= ENV["GCLOUD_TEST_KEYFILE_JSON"]
  end
  if project.nil? || keyfile.nil?
    fail "You must provide a project and keyfile. e.g. rake acceptance[test123, /path/to/keyfile.json] or GCLOUD_TEST_PROJECT=test123 GCLOUD_TEST_KEYFILE=/path/to/keyfile.json rake acceptance"
  end
  # always overwrite when running tests
  ENV["GOOGLE_CLOUD_PROJECT"] = project
  ENV["GOOGLE_CLOUD_KEYFILE"] = nil
  ENV["GOOGLE_CLOUD_KEYFILE_JSON"] = keyfile

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

desc "Runs yard-doctest example tests for all gems individually."
task :doctest, :bundleupdate do |t, args|
  bundleupdate = args[:bundleupdate]
  Rake::Task["bundleupdate"].invoke if bundleupdate
  header "Running yard-doctest example code tests"
  gems.each do |gem|
    Dir.chdir gem do
      Bundler.with_clean_env do
        header "DOCTEST FOR #{gem}"
        sh "bundle exec rake doctest"
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

namespace :jsondoc do
  # @param tag [String] A valid tag, e.g. "v0.10.0" (legacy), "google-cloud-datastore:v1.2.0", or "master".
  desc "Clones gh-pages branch to a temp dir"
  task :init, :tag do |t, args|
    tag = args[:tag]
    fail "Missing required parameter 'tag'." if tag.nil?
    gh_pages = Pathname.new(Dir.home) + "tmp/#{tag}-gh-pages"

    header "Cloning gh-pages branch to #{gh_pages}"

    FileUtils.remove_dir gh_pages if Dir.exists? gh_pages
    FileUtils.mkdir_p gh_pages

    # checkout the gh-pages branch
    git_repo = "git@github.com:GoogleCloudPlatform/google-cloud-ruby.git"
    if ENV["GH_OAUTH_TOKEN"]
      git_repo = "https://#{ENV["GH_OAUTH_TOKEN"]}@github.com/#{ENV["GH_OWNER"]}/#{ENV["GH_PROJECT_NAME"]}"
    end
    puts "git clone --quiet --branch=gh-pages --single-branch #{git_repo} #{gh_pages} > /dev/null"
    puts `git clone --quiet --branch=gh-pages --single-branch #{git_repo} #{gh_pages} > /dev/null`
  end

  desc "Copies jsondoc to gh-pages repo in temp dir."
  task :copy, [:tag] => [:jsondoc, :init] do |t, args|
    tag = args[:tag]
    fail "Missing required parameter 'tag'." if tag.nil?
    gh_pages = Pathname.new(Dir.home) + "tmp/#{tag}-gh-pages"

    header "Copying all jsondoc for branch/tag '#{tag}' to '#{gh_pages}'"
    gems.each do |gem|
      unless Dir.exist? gh_pages + "json/#{gem}"
        mkdir_p gh_pages + "json/#{gem}", verbose: true
      end
      gem_version = tag.include?(":") ? tag.split(":").last : tag
      cp_r "#{gem}/jsondoc", gh_pages + "json/#{gem}/#{gem_version}", verbose: true
    end
    cp "docs/manifest.json", gh_pages, verbose: true
    cp "docs/json/home.html", gh_pages + "json", verbose: true
  end

  desc "Assembles google-cloud umbrella package jsondoc, from gems' jsondoc to gh-pages repo in temp dir."
  task :umbrella, [:tag] => [:copy] do |t, args|
    tag = args[:tag]
    fail "Missing required parameter 'tag'." if tag.nil?
    gh_pages = Pathname.new(Dir.home) + "tmp/#{tag}-gh-pages"

    require "json"
    excluded = ["gcloud", "google-cloud"]
    all_types = []
    google_cloud_json = JSON.parse File.read("google-cloud/jsondoc/google/cloud.json")

    # Load existing google/cloud.json methods.
    all_google_cloud_methods = [google_cloud_json["methods"]]

    header "Copying all jsondoc to google-cloud umbrella package"
    gems.each do |gem|
      next if excluded.include? gem
      gem_shortname = gem[/\Agoogle-cloud-(.+)/, 1]
      gem_shortname = gem_shortname.gsub "_", "" # "resource_manager" -> "resourcemanager"
      unless gem == "google-cloud-core" # There is no `core` subdir
        cp_r "#{gem}/jsondoc/google/cloud/#{gem_shortname}", gh_pages + "json/google-cloud/master/google/cloud/", verbose: true
      end
      cp Dir["#{gem}/jsondoc/google/cloud/*.json"], gh_pages + "json/google-cloud/master/google/cloud/", verbose: true
      all_types << JSON.parse(File.read("#{gem}/jsondoc/types.json"))
      all_google_cloud_methods << JSON.parse(File.read("#{gem}/jsondoc/google/cloud.json"))["methods"]
    end

    header "Merging each gem types.json into #{gh_pages}/json/google-cloud/jsondoc/types.json"
    File.open(gh_pages + "json/google-cloud/master/types.json", "w") do |f|
      f.write(all_types.flatten.to_json)
    end

    header "Merging methods from each google/cloud.json into #{gh_pages}/json/google-cloud/jsondoc/google/cloud.json"
    all_google_cloud_methods.each {|x| x.each {|y| puts y["id"]}}
    google_cloud_json["methods"] = all_google_cloud_methods.flatten
    File.open(gh_pages + "json/google-cloud/master/google/cloud.json", "w") do |f|
      f.write(google_cloud_json.to_json)
    end
  end

  desc "Publishes assembled jsondoc to gh-pages"
  task :publish, [:tag] => [:umbrella] do |t, args|
    tag = args[:tag]
    fail "Missing required parameter 'tag'." if tag.nil?
    gh_pages = Pathname.new(Dir.home) + "tmp/#{tag}-gh-pages"

    git_ref = tag == "master" ? `git rev-parse --short HEAD`.chomp : tag
    # Change to gh-pages
    puts "cd #{gh_pages}"
    Dir.chdir gh_pages do
      # commit changes
      puts `git add -A .`
      if ENV["GH_OAUTH_TOKEN"]
        puts `git config --global user.email "travis@travis-ci.org"`
        puts `git config --global user.name "travis-ci"`
        puts `git commit -m "Update documentation for #{git_ref}"`
        puts `git push -q #{git_repo} gh-pages:gh-pages`
      else
        puts `git commit -m "Update documentation for #{git_ref}"`
        puts `git push -q origin gh-pages`
      end
    end
  end

  desc "Publishes the jsondoc for master branch to the gh-pages branch"
  task :master do
    unless ENV["GH_OAUTH_TOKEN"]
      # only check this if we are not running on travis
      branch = `git symbolic-ref --short HEAD`.chomp
      if "master" != branch
        puts "You are on the #{branch} branch. You must be on the master branch to run this rake task."
        exit
      end

      unless `git status --porcelain`.chomp.empty?
        puts "The master branch is not clean. Unable to update gh-pages."
        exit
      end
    end
    Rake::Task["jsondoc:publish"].invoke("master")
  end

  desc "Publishes the jsondoc for the tag to the gh-pages branch"
  task :tag, :tag do |t, args|
    tag = args[:tag]
    fail "Missing required parameter 'tag'." if tag.nil?
    # Verify the tag exists
    tag_check = `git show-ref --tags | grep #{tag}`.chomp
    if tag_check.empty?
      fail "Cannot find the tag '#{tag}'."
    end

    git_repo = "git@github.com:GoogleCloudPlatform/google-cloud-ruby.git"
    if ENV["GH_OAUTH_TOKEN"]
      git_repo = "https://#{ENV["GH_OAUTH_TOKEN"]}@github.com/#{ENV["GH_OWNER"]}/#{ENV["GH_PROJECT_NAME"]}"
    end

    tag_repo  =  Pathname.new(Dir.home) + "tmp/#{tag}-repo"
    FileUtils.remove_dir tag_repo if Dir.exists? tag_repo
    FileUtils.mkdir_p tag_repo

    header "Cloning tag #{tag} to #{tag_repo}"

    # checkout the tag repo
    puts "git clone --quiet --branch=#{tag} --single-branch #{git_repo} #{tag_repo} > /dev/null"
    puts `git clone --quiet --branch=#{tag} --single-branch #{git_repo} #{tag_repo} > /dev/null`
    # build the docs in the tag repo
    Dir.chdir tag_repo do
      Bundler.with_clean_env do
        # create the docs
        puts "bundle install --path .bundle"
        puts `bundle install --path .bundle`
        puts "bundle exec rake jsondoc:publish[\"#{tag}\"]"
        puts `bundle exec rake jsondoc:publish["#{tag}"]`
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
  desc "Runs acceptance tests for Travis-CI."
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

  desc "Runs post-build logic on Travis-CI."
  task :post do
    # We don't run post-build on pull requests
    if ENV["TRAVIS_PULL_REQUEST"] == "false" && ENV["GCLOUD_BUILD_DOCS"] == "true"

      if ENV["TRAVIS_BRANCH"] == "master"
        # TODO: Call JSONDOC task for master here
      elsif ENV["TRAVIS_TAG"]
        tag = ENV["TRAVIS_TAG"]
        # Verify the tag format "PACKAGE/vVERSION"
        m = tag.match /(?<package>\S*)\/v(?<version>\S*)/
        if m # We have a match!
          Rake::Task["travis:release"].invoke m[:package], m[:version], ENV["RUBYGEMS_API_TOKEN"]
          # TODO: Call JSONDOC task for release here
        end
      end
    end
  end

  task :release, :package, :version, :api_token do |t, args|
    package = args[:package]
    version = args[:version]
    api_token = args[:api_token]
    if package.nil? || version.nil?
      fail "You must provide a package and version."
    end

    require "gems"
    ::Gems.configure do |config|
      config.key = api_token
    end if api_token

    Dir.chdir package do
      Bundler.with_clean_env do
        sh "rm -rf pkg"
        sh "bundle update"
        sh "rake build"
      end
    end

    path_to_be_pushed = "#{package}/pkg/#{package}-#{version}.gem"
    if File.file? path_to_be_pushed
      begin
        ::Gems.push(File.new path_to_be_pushed)
        puts "Successfully built and pushed #{package} for version #{version}"
      rescue => e
        puts "Error while releasing #{package} version #{version}: #{e.message}"
      end
    else
      fail "Cannot build #{package} for version #{version}"
    end
  end
end

namespace :appveyor do
  desc "Runs acceptance tests for AppVeyor CI."
  task :acceptance do
    if ENV["APPVEYOR_REPO_BRANCH"] == "master" && !ENV["APPVEYOR_PULL_REQUEST_NUMBER"]
      header "Running acceptance tests on AppVeyor"
      # Fix for SSL certificates on AppVeyor
      ENV["SSL_CERT_FILE"] = Gem.loaded_specs["google-api-client"].full_gem_path + "/lib/cacerts.pem"
      Rake::Task["acceptance"].invoke
    else
      header "Skipping acceptance tests on AppVeyor"
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
