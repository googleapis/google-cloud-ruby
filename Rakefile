require "bundler/setup"
require "open3"
require "json"

task :circletest do
  puts "Testing circleCI!"
  puts "Tag is #{ENV['CIRCLE_TAG'].inspect}"
end

task :bundleupdate do
  valid_gems.each do |gem|
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
  valid_gems.each do |gem|
    Dir.chdir gem do
      Bundler.with_clean_env do
        header "RUNNING #{gem}"
        sh "bundle update" if bundleupdate
        header "#{gem} rubocop", "*"
        run_task_if_exists "rubocop"
        header "#{gem} jsondoc", "*"
        run_task_if_exists "jsondoc"
        header "#{gem} doctest", "*"
        run_task_if_exists "doctest"
        header "#{gem} test", "*"
        sh "bundle exec rake test"
      end
    end
  end
end

desc "Runs tests for all gems."
task :test => :compile do
  require "active_support/all"
  valid_gems.each do |gem|
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
    valid_gems.each do |gem|
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
      valid_gems_with_coverage_filters.each do |gem, filters|
        filters.each { |filter| add_filter filter }
        add_group gem, "#{gem}/lib"
      end
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
task :acceptance, [:project, :keyfile, :key] => :compile do |t, args|
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
  ENV["GCLOUD_TEST_PROJECT"] = project
  ENV["GCLOUD_TEST_KEYFILE"] = nil
  ENV["GCLOUD_TEST_KEYFILE_JSON"] = keyfile

  key = args[:key] || ENV["GCLOUD_TEST_KEY"]
  if key.nil?
    fail "You must provide an API KEY for translate acceptance tests."
  end  # always overwrite when running tests
  ENV["GCLOUD_TEST_KEY"] = key

  valid_gems.each do |gem|
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
    valid_gems.each do |gem|
      Dir.chdir gem do
        Bundler.with_clean_env do
          header "ACCEPTANCE TESTS FOR #{gem}"
          sh "bundle exec rake acceptance -v"
        end
      end
    end
  end

  # Runs each gem's acceptance tests without verifying that a test environment
  # is used. May delete production data! Use only with caution!
  task :unsafe, :bundleupdate do |t, args|
    bundleupdate = args[:bundleupdate]
    Rake::Task["bundleupdate"].invoke if bundleupdate
    valid_gems.each do |gem|
      Dir.chdir gem do
        Bundler.with_clean_env do
          header "UNSAFE ACCEPTANCE TESTS FOR #{gem}"
          sh "bundle exec rake acceptance:run -v"
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
      valid_gems.each { |gem| add_group gem, "#{gem}/lib" }
    end

    header "Running acceptance tests and coverage report"
    Rake::Task["acceptance"].invoke
  end

  desc "Runs acceptance:cleanup for all gems."
  task :cleanup, :bundleupdate do |t, args|
    bundleupdate = args[:bundleupdate]
    Rake::Task["bundleupdate"].invoke if bundleupdate
    valid_gems.each do |gem|
      cd gem do
        Bundler.with_clean_env do
          run_task_if_exists "acceptance:cleanup"
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
  valid_gems.each do |gem|
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
  valid_gems.each do |gem|
    Dir.chdir gem do
      Bundler.with_clean_env do
        header "DOCTEST FOR #{gem}"
        run_task_if_exists "doctest"
      end
    end
  end
end

desc "Runs jsondoc report for all gems individually."
task :jsondoc, :bundleupdate do |t, args|
  bundleupdate = args[:bundleupdate]
  Rake::Task["bundleupdate"].invoke if bundleupdate
  header "Running jsondoc reports"
  valid_gems.each do |gem|
    Dir.chdir gem do
      Bundler.with_clean_env do
        header "JSONDOC FOR #{gem}"
        sh "bundle exec rake jsondoc"
      end
    end
  end
end

namespace :jsondoc do
  desc "Clones gh-pages branch to a temp dir"
  task :clone_gh_pages, [:gh_pages_dir] do |t, args|
    gh_pages_dir = extract_args args, :gh_pages_dir
    gh_pages = gh_pages_path gh_pages_dir
    header "Cloning gh-pages branch to #{gh_pages}"

    FileUtils.remove_dir gh_pages if Dir.exists? gh_pages
    FileUtils.mkdir_p gh_pages

    # checkout the gh-pages branch
    sh "git clone --quiet --branch=gh-pages --single-branch #{git_repo} #{gh_pages} > /dev/null"
  end

  desc "Copies a gem's jsondoc to gh-pages repo in temp dir."
  task :copy, [:gem, :version, :gh_pages_dir] do |t, args|
    gem, version, gh_pages_dir = extract_args args, :gem, :version, :gh_pages_dir
    gh_pages = gh_pages_path gh_pages_dir

    header "Copying #{gem} jsondoc for '#{gem}/#{version}' to '#{gh_pages}'"

    unless Dir.exist? gh_pages + "json/#{gem}"
      mkdir_p gh_pages + "json/#{gem}", verbose: true
    end
    rm_rf gh_pages + "json/#{gem}/#{version}", verbose: true
    cp_r "#{gem}/jsondoc", gh_pages + "json/#{gem}/#{version}", verbose: true

    cp "docs/manifest.json", gh_pages, verbose: true
    cp "docs/json/home.html", gh_pages + "json", verbose: true
  end

  desc "Updates a gem's toc.json with correct tagName."
  task :toc, [:gem, :version, :gh_pages_dir] => [:copy] do |t, args|
    gem, version, gh_pages_dir = extract_args args, :gem, :version, :gh_pages_dir
    gh_pages = gh_pages_path gh_pages_dir

    header "Updating toc.json for '#{gem}/#{version}' in '#{gh_pages}'"
    toc_path = gh_pages + "json/#{gem}/#{version}" + "toc.json"
    toc_json = JSON.parse File.read(toc_path)
    toc_json["tagName"] = "#{gem}/#{version}"
    puts "Updating #{toc_path}"
    File.write toc_path, JSON.generate(toc_json) + "\n"
  end

  desc "Assembles the google-cloud package gh-pages jsondoc, from gems' gh-pages jsondoc, using latest versions."
  task :google_cloud, [:version, :gh_pages_dir] do |t, args|
    version, gh_pages_dir = extract_args args, :version, :gh_pages_dir
    gh_pages = gh_pages_path gh_pages_dir

    all_types = []
    google_cloud_json = JSON.parse File.read("google-cloud/jsondoc/google/cloud.json")

    # Load existing google/cloud.json methods.
    all_google_cloud_methods = [google_cloud_json["methods"]]

    header "Copying all gems' jsondoc from gh-pages to google-cloud package in gh-pages"

    rm_rf gh_pages + "json/google-cloud/#{version}/google", verbose: true

    google_cloud_gems = [
      # Place bigquery-data_transfer ahead of bigquery to avoid overwriting the
      # google/cloud/bigquery.json "guide" with blank output. See issue #2007.
      "google-cloud-bigquery-data_transfer",
      "google-cloud-bigquery",
      "google-cloud-container",
      "google-cloud-core",
      "google-cloud-dataproc",
      "google-cloud-datastore",
      "google-cloud-dialogflow",
      "google-cloud-dlp",
      "google-cloud-dns",
      "google-cloud-error_reporting",
      "google-cloud-firestore",
      "google-cloud-language",
      "google-cloud-logging",
      "google-cloud-monitoring",
      "google-cloud-os_login",
      "google-cloud-pubsub",
      "google-cloud-resource_manager",
      "google-cloud-spanner",
      "google-cloud-speech",
      "google-cloud-storage",
      "google-cloud-tasks",
      "google-cloud-text_to_speech",
      "google-cloud-trace",
      "google-cloud-translate",
      "google-cloud-video_intelligence",
      "google-cloud-vision"
    ]
    # Currently excluded: "gcloud", "google-cloud", "stackdriver", "stackdriver-core",
    #                     "google-cloud-spanner", "google-cloud-env"
    (google_cloud_gems & gems).each do |gem|

      ver = if version == "master"
              "master" # When building master, all content should be from master
            else
              v = manifest_versions[gem]
              puts "Using latest #{gem} version '#{v}' (from docs/manifest.json)"
              v
            end

      src = gh_pages + "json/#{gem}/#{ver}"

      gem_shortname = gem[/\Agoogle-cloud-(.+)/, 1]
      gem_shortname = gem_shortname.gsub "_", "" # "resource_manager" -> "resourcemanager"

      header_2 "Copying #{gem_shortname} jsondoc from gh-pages to google-cloud package in gh-pages"

      # Copy the contents of google/cloud/ for the gem. This also gets the core error files.
      cp_r "#{src}/google", gh_pages + "json/google-cloud/#{version}/", verbose: true
      all_types << JSON.parse(File.read("#{src}/types.json"))
      all_google_cloud_methods << JSON.parse(File.read("#{src}/google/cloud.json"))["methods"]
    end

    header "Merging each gem types.json into #{gh_pages}/json/google-cloud/#{version}/types.json"
    File.write gh_pages + "json/google-cloud/#{version}/types.json", all_types.flatten.to_json

    header "Merging methods from each google/cloud.json into #{gh_pages}/json/google-cloud/#{version}/google/cloud.json"
    all_google_cloud_methods.each {|x| x.each {|y| puts y["id"]}}
    google_cloud_json["methods"] = all_google_cloud_methods.flatten
    File.write gh_pages + "json/google-cloud/#{version}/google/cloud.json", google_cloud_json.to_json
  end

  desc "Assembles the stackdriver package jsondoc, from gems' jsondoc to gh-pages repo in temp dir."
  task :stackdriver, [:version, :gh_pages_dir] do |t, args|
    version, gh_pages_dir = extract_args args, :version, :gh_pages_dir
    gh_pages = gh_pages_path gh_pages_dir

    header "Copying reference docs from gh-pages to stackdriver package in gh-pages"

    unless Dir.exists? gh_pages + "json/stackdriver/#{version}/google/cloud"
      mkdir_p gh_pages + "json/stackdriver/#{version}/google/cloud", verbose: true
    end

    gems.each do |gem|
      next unless stackdriver_gems.include? gem

      ver = if version == "master"
              "master"
            else
              v = manifest_versions[gem]
              puts "Using latest #{gem} version '#{v}' (from docs/manifest.json)"
              v
            end

      src = gh_pages + "json/#{gem}/#{ver}"

      gem_shortname = gem[/\Agoogle-cloud-(.+)/, 1]
      gem_shortname = gem_shortname.gsub "_", "" # "resource_manager" -> "resourcemanager"
      # Copy all the .md files from each gem
      rm_rf gh_pages + "json/stackdriver/#{version}/google/cloud/#{gem_shortname}", verbose: true
      mkdir_p gh_pages + "json/stackdriver/#{version}/google/cloud/#{gem_shortname}", verbose: true
      cp Dir.glob("#{src}/*.md"),
         gh_pages + "json/stackdriver/#{version}/google/cloud/#{gem_shortname}",
         verbose: true
    end
  end

  desc "Publishes the jsondoc changes in the tmp dir cloned repo, gh-pages"
  task :publish, [:tag, :gh_pages_dir] do |t, args|
    tag, gh_pages_dir = extract_args args, :tag, :gh_pages_dir
    gh_pages = gh_pages_path gh_pages_dir

    git_ref = tag == "master" ? `git rev-parse --short HEAD`.chomp : tag
    # Change to gh-pages
    puts "cd #{gh_pages}"
    Dir.chdir gh_pages do
      # commit changes
      sh "git add -A ."
      unless `git status --porcelain`.chomp.empty?
        if ENV["GH_OAUTH_TOKEN"]
          sh "git config --global user.email \"travis@travis-ci.org\""
          sh "git config --global user.name \"travis-ci\""
          sh "git commit -m \"Update documentation for #{git_ref}\""
          sh "git push -q #{git_repo} gh-pages:gh-pages"
        else
          sh "git commit -m \"Update documentation for #{git_ref}\""
          sh "git push -q origin gh-pages"
        end
      end
    end
  end

  desc "Generates the jsondoc for master branch for all gems, updates google-cloud with all gems' master branch, publishes."
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

    gh_pages_dir = "all-master-gh-pages"

    Rake::Task["jsondoc"].invoke
    Rake::Task["jsondoc:clone_gh_pages"].invoke(gh_pages_dir)
    gems.each do |gem|
      Rake::Task["jsondoc:toc"].invoke(gem, "master", gh_pages_dir)
      Rake::Task["jsondoc:toc"].reenable
      Rake::Task["jsondoc:copy"].reenable
    end
    Rake::Task["jsondoc:google_cloud"].invoke("master", gh_pages_dir)
    Rake::Task["jsondoc:stackdriver"].invoke("master", gh_pages_dir)
    Rake::Task["jsondoc:publish"].invoke("master", gh_pages_dir)
  end

  # Usage: rake jsondoc:package["google-cloud-vision/v0.21.1"]
  desc "Generates the jsondoc for the gem and version in the given tag, updates google-cloud with all gems' latest versions, publishes."
  task :package, [:tag] do |t, args|
    tag = extract_args args, :tag
    gem, version = split_tag tag

    # Verify the tag exists
    `git fetch`
    tag_check = `git show-ref --tags | grep #{tag}`.chomp
    if tag_check.empty?
      fail "Cannot find the tag '#{tag}'."
    end

    Dir.chdir gem do
      Bundler.with_clean_env do
        header "JSONDOC FOR #{gem}"
        # TODO: checkout tag repo (see TODO below), and execute following command in that repo.
        sh "bundle exec rake jsondoc"
      end
    end

    gh_pages_dir = "#{gem}-#{version}-gh-pages"

    Rake::Task["jsondoc:clone_gh_pages"].invoke(gh_pages_dir)
    Rake::Task["jsondoc:toc"].invoke(gem, version, gh_pages_dir)

    excluded_google_cloud_gems = ["gcloud", "stackdriver"]
    unless excluded_google_cloud_gems.include? gem
      google_cloud_version = manifest_versions["google-cloud"]
      header "Assembling jsondoc for google-cloud package"
      puts "Latest google-cloud package version is '#{google_cloud_version}' (from docs/manifest.json)."
      Rake::Task["jsondoc:google_cloud"].invoke(google_cloud_version, gh_pages_dir)
    end

    if stackdriver_gems.include? gem
      stackdriver_version = manifest_versions["stackdriver"]
      header "Assembling jsondoc for stackdriver package"
      puts "Latest stackdriver package version is '#{stackdriver_version}' (from docs/manifest.json)"
      Rake::Task["jsondoc:stackdriver"].invoke(stackdriver_version, gh_pages_dir)
    end

    Rake::Task["jsondoc:publish"].invoke(tag, gh_pages_dir)
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

namespace :circleci do
  desc "Build for CircleCI"
  task :build do
    run_acceptance = false
    if ENV["CIRCLE_BRANCH"] == "master" && ENV["CIRCLE_PR_NUMBER"].nil?
      run_acceptance = true
    end

    valid_gems.each do |gem|
      Dir.chdir gem do
        Bundler.with_clean_env do
          sh "bundle update"

          if run_acceptance
            sh "bundle exec rake ci:acceptance"
          else
            sh "bundle exec rake ci"
          end
        end
      end
    end
  end

  desc "Runs post-build logic on CircleCI."
  task :post do
    # We don't run post-build on pull requests
    if ENV["CIRCLE_PR_NUMBER"].nil?
      if ENV["CIRCLE_BRANCH"] == "master"
        Rake::Task["bundleupdate"].invoke
        Rake::Task["jsondoc:master"].invoke
      end
    end
  end

  task :release do
    tag = ENV["CIRCLE_TAG"]
    if tag.nil?
      fail "You must provide a tag to release."
    end

    Rake::Task["release"].invoke tag
  end
end

namespace :travis do
  desc "Build for Travis-CI"
  task :build do
    run_acceptance = false
    if ENV["TRAVIS_BRANCH"] == "master" &&
       ENV["TRAVIS_PULL_REQUEST"] == "false"
      run_acceptance = true
    end

    valid_gems.each do |gem|
      Dir.chdir gem do
        Bundler.with_clean_env do
          sh "gem install bundler"
          sh "bundle update"

          if run_acceptance
            sh "bundle exec rake ci:acceptance"
          else
            sh "bundle exec rake ci"
          end
        end
      end
    end
  end
end

namespace :appveyor do
  desc "Build for AppVeyor"
  task :build do
    # Retrieve the SSL certificate from google-api-client gem
    ssl_cert_file = Gem.loaded_specs["google-api-client"].full_gem_path + "/lib/cacerts.pem"

    run_acceptance = false
    if ENV["APPVEYOR_REPO_BRANCH"] == "master" && !ENV["APPVEYOR_PULL_REQUEST_NUMBER"]
      run_acceptance = true
    end

    valid_gems.each do |gem|
      Dir.chdir gem do
        Bundler.with_clean_env do
          # Fix acceptance/data symlinks on windows
          require "fileutils"
          FileUtils.mkdir_p "acceptance"
          FileUtils.rm_f "acceptance/data"
          sh "call mklink /j acceptance\\data ..\\acceptance\\data"

          sh "bundle update"

          if run_acceptance
            # Set the SSL certificate so connections can be made
            ENV["SSL_CERT_FILE"] = ssl_cert_file

            sh "bundle exec rake ci:acceptance"
          else
            sh "bundle exec rake ci"
          end
        end
      end
    end
  end
end

desc "Run the CI build for all gems."
task :ci, :bundleupdate do |t, args|
  bundleupdate = args[:bundleupdate]
  valid_gems.each do |gem|
    Dir.chdir gem do
      Bundler.with_clean_env do
        sh "bundle update" if bundleupdate
        sh "bundle exec rake ci"
      end
    end
  end
end
namespace :ci do
  desc "Run the CI build, with acceptance tests, for all gems."
  task :acceptance, :bundleupdate do |t, args|
    bundleupdate = args[:bundleupdate]
    valid_gems.each do |gem|
      Dir.chdir gem do
        Bundler.with_clean_env do
          sh "bundle update" if bundleupdate
          sh "bundle exec rake ci:acceptance"
        end
      end
    end
  end
  task :a do
    # This is a handy shortcut to save typing
    Rake::Task["ci:acceptance"].invoke
  end
end

task :release, :tag do |t, args|
  tag = args[:tag]
  if tag.nil?
    fail "You must provide a tag to release."
  end
  # Verify the tag format "PACKAGE/vVERSION"
  m = tag.match /(?<package>\S*)\/v(?<version>\S*)/
  if m.nil? # We have a match!
    fail "Tag #{tag} does not match the expected format."
  end

  package = m[:package]
  version = m[:version]
  if package.nil? || version.nil?
    fail "You must provide a package and version."
  end

  api_token = ENV["RUBYGEMS_API_TOKEN"]

  require "gems"
  ::Gems.configure do |config|
    config.key = api_token
  end if api_token

  Dir.chdir package do
    Bundler.with_clean_env do
      sh "rm -rf pkg"
      sh "bundle update"
      sh "bundle exec rake build"
    end
  end

  path_to_be_pushed = "#{package}/pkg/#{package}-#{version}.gem"
  if File.file? path_to_be_pushed
    begin
      ::Gems.push(File.new path_to_be_pushed)
      puts "Successfully built and pushed #{package} for version #{version}"

      Rake::Task["jsondoc:package"].invoke tag
    rescue => e
      puts "Error while releasing #{package} version #{version}: #{e.message}"
    end
  else
    fail "Cannot build #{package} for version #{version}"
  end
end

desc "Run all integration tests"
task :integration, :project_uri, :bundleupdate do |t, args|
  bundleupdate = args[:bundleupdate]
  Rake::Task["bundleupdate"].invoke if bundleupdate
  sh "bundle exec rake integration:gae[#{args[:project_uri]}]"
  sh "bundle exec rake integration:gke"
end

namespace :integration do
  desc "Run integration:gae for all gems"
  task :gae, :project_uri do |t, args|
    require_relative "integration/deploy"

    if executable_exists? "gcloud"
      project_id = gcloud_project_id
      fail "Unabled to determine project_id from gcloud SDK. Please make " \
        "sure gcloud SDK is logged in and a valid project ID is configured." unless project_id
      # If project_uri not given, default to "http://[project_id].appspot-preview.com"
      project_uri = args[:project_uri] ||
                    "http://#{project_id}.appspot-preview.com"

      fail "You must provide a project_uri. e.g. rake " \
        "integration:gae[http://my-project.appspot-preview.com]" if project_uri.nil?

      test_apps = Dir.glob("integration/*_app").select {|f| File.directory? f}

      test_apps.each do |test_app|
        header "Deploying #{test_app} to GAE Flex"
        deploy_gae_flex test_app, project_uri do
          valid_gems.each do |gem|
            Dir.chdir gem do
              header "Running integration:gae for gem #{gem}"
              Bundler.with_clean_env do
                run_task_if_exists "integration:gae", project_uri
              end
            end
          end
        end
      end
    else
      header "Unable to find gcloud SDK. Skip tests. Please reference https://cloud.google.com/sdk/ on installing gcloud SDK and kubernetes CTL."
    end
  end

  desc "Run integration:gke for all gems"
  task :gke do
    require_relative "integration/deploy"

    unless executable_exists? "gcloud"
      fail "Unable to find gcloud SDK. Please reference https://cloud.google.com/sdk/ on how to install."
    end
    unless executable_exists? "kubectl"
      fail "Unable to find Kubernetes CTL. You can install it through \"gcloud components install kubectl\"."
    end
    unless executable_exists? "docker"
      fail "Unable to find Docker. Please reference https://docs.docker.com/engine/installation/ on how to install."
    end

    project_id = gcloud_project_id
    fail "Unabled to determine project_id from gcloud SDK. Please make " \
      "sure gcloud SDK is logged in and a valid project ID is configured." unless project_id

    test_apps = Dir.glob("integration/*_app").select {|f| File.directory? f}

    test_apps.each do |test_app|
      header "Building #{test_app} docker image"
      build_docker_image test_app, project_id do |image_name, image_location|
        header "Pushing docker image #{image_name} to GCR"
        push_docker_image project_id, image_name, image_location do |image_name, image_location|
          header "Deploying docker image #{image_location}"
          deploy_gke_image image_name, image_location do |pod_name|
            # Invoke integration:gke with on each gem
            valid_gems.each do |gem|
              Dir.chdir gem do
                Bundler.with_clean_env do
                  header "Running integration:gke for gem #{gem}"
                  run_task_if_exists "integration:gke", pod_name
                end
              end
            end
          end
        end
      end
    end
  end
end

desc "Print all the changes since the last release."
task :changes, [:gem] do |t, args|
  gem = args[:gem]
  if gem
    Rake::Task["changes:log"].invoke gem
    Rake::Task["changes:diff"].invoke gem
  else # Print git log for all gems except the meta-packages
    valid_gems.each do |gem|
      begin
        tag = current_release_tag gem
        stats = (`git diff --stat #{tag}..master #{gem}`).split("\n")
        if stats.empty?
          puts "#{gem}: no changes"
        else
          puts "#{gem}:#{stats.last} (#{oldest_commit_since_release gem, tag})"
        end
      rescue
        puts "#{gem}: not yet released"
      end
    end
  end
end
namespace :changes do
  desc "Print a diff of the changes since the last release."
  task :diff, [:gem] do |t, args|
    gem = args[:gem]
    tag = current_release_tag gem
    sh "git diff #{tag}..master #{gem}"
  end

  desc "Print the logs of changes since the last release."
  task :log, [:gem] do |t, args|
    gem = args[:gem]
    tag = current_release_tag gem
    sh "git log #{tag}..master #{gem}"
  end

  desc "Print the stats of changes since the last release."
  task :stats, [:gem] do |t, args|
    gems = Array args[:gem]
    gems = valid_gems if gems.empty?
    gems.each do |gem|
      begin
        header gem
        tag = current_release_tag gem
        sh "git diff --stat #{tag}..master #{gem}"
      rescue => e
        puts e
      end
    end
  end

  desc "Print the commits of changes since the last release."
  task :commits, [:gem] do |t, args|
    gems = Array args[:gem]
    gems = valid_gems if gems.empty?
    gems.each do |gem|
      begin
        header gem
        tag = current_release_tag gem
        sh "git log --pretty=format:\"%h%x09%an%x09%ad%x09%s\" --date=relative #{tag}..master #{gem}"
      rescue => e
        puts e
      end
    end
  end

  def current_release_tag gem
    tags = `git tag --sort=-creatordate | grep #{gem}/v`.split
    fail "Cannot find a release for #{gem}" unless tags.any?
    tags.first
  end

  def oldest_commit_since_release gem, tag
    commit_dates = (`git log --pretty=format:\"%ad\" --date=relative #{tag}..master #{gem}`).split("\n")
    commit_dates.last
  end
end

desc "Compile each gems"
task :compile do
  gems_with_ext = valid_gems.select { |gem|
    spec = Gem::Specification::load("#{gem}/#{gem}.gemspec")
    !spec.extensions.empty?
  }
  gems_with_ext.each do |gem|
    Dir.chdir gem do
      Bundler.with_clean_env do
        header "Compile C extension for #{gem}"
        sh "bundle update"
        sh "bundle exec rake compile"
      end
    end
  end
end

def gems
  `git ls-files -- */*.gemspec`.split("\n").map { |gem| gem.split("/").first }.sort
end

def valid_gems
  gems.select { |gem|
    spec = Gem::Specification::load("#{gem}/#{gem}.gemspec")
    spec.required_ruby_version.satisfied_by? Gem::Version.new(RUBY_VERSION)
  }
end

def valid_gems_with_coverage_filters
  coverage_override = {
    "google-cloud-datastore" => ["google-cloud-datastore/test/", "google-cloud-datastore/lib/google/datastore/", "google-cloud-datastore/lib/google/cloud/datastore/v1/"],
    "google-cloud-language" => ["google-cloud-language/test/", "google-cloud-language/lib/google/cloud/language/v1/"],
    "google-cloud-logging" => ["google-cloud-logging/test/", "google-cloud-logging/lib/google/logging/", "google-cloud-logging/lib/google/cloud/logging/v2/"],
    "google-cloud-pubsub" => ["google-cloud-pubsub/test/", "google-cloud-pubsub/lib/google/pubsub/", "google-cloud-pubsub/lib/google/cloud/pubsub/v1/"],
    "google-cloud-spanner" => ["google-cloud-spanner/test/", "google-cloud-spanner/lib/google/spanner/", "google-cloud-spanner/lib/google/cloud/spanner/v1/", "google-cloud-spanner/lib/google/cloud/spanner/admin/instance/v1/", "google-cloud-spanner/lib/google/cloud/spanner/admin/database/v1/"],
    "google-cloud-speech" => ["google-cloud-speech/test/", "google-cloud-speech/lib/google/cloud/speech/v1/"],
    "google-cloud-vision" => ["google-cloud-vision/test/", "google-cloud-vision/lib/google/cloud/vision/v1/"]
  }

  coverage = Hash[valid_gems.map { |gem| [gem, ["#{gem}/test/"]] }]
  coverage.merge coverage_override
end

def header str, token = "#"
  line_length = str.length + 8
  puts ""
  puts token * line_length
  puts "#{token * 3} #{str} #{token * 3}"
  puts token * line_length
  puts ""
end

def header_2 str, token = "#"
  puts "\n#{token * 3} #{str} #{token * 3}\n"
end

# Returns [gem_name, gem_version]
def split_tag str
  return [nil, str] if str == "master" # Support use of "master" even without gem name
  fail "'tag' must be in the format <gem>/<version> Actual: #{str}" unless str.include?("/")
  parts = str.split("/")
  fail "'tag' must be in the format <gem>/<version>. Actual: #{str}" unless parts.length == 2
  parts
end

##
# Run rake task if exists on commandline. Used to run rake tasks in
# subdirectories.
def run_task_if_exists task_name, params = ""
  if `bundle exec rake --tasks #{task_name}` =~ /#{task_name}[^:]/
    sh "bundle exec rake #{task_name}[#{params}]"
  end
end

def gh_pages_path gh_pages_dir
  Pathname.new(Dir.home) + "tmp" + gh_pages_dir
end

def git_repo
  @git_repo ||= git_repository
end

def git_repository
  if ENV["GH_OAUTH_TOKEN"]
    "https://#{ENV["GH_OAUTH_TOKEN"]}@github.com/#{ENV["GH_OWNER"]}/#{ENV["GH_PROJECT_NAME"]}"
  else
    "git@github.com:GoogleCloudPlatform/google-cloud-ruby.git"
  end
end

def manifest_versions
  @manifest_versions ||= read_docs_manifest_versions
end

def read_docs_manifest_versions
  manifest = JSON.parse File.read("docs/manifest.json")
  manifest["modules"].each_with_object({}) do |gem, memo|
    memo[gem["name"]] = gem["versions"].first
  end
end

def extract_args args, *keys
  vals = keys.map do |key|
    fail "Missing required parameter '#{key}'." unless args[key]
    args[key]
  end
  vals.length > 1 ? vals : vals.first
end

def stackdriver_gems
  ["google-cloud-logging",
   "google-cloud-error_reporting",
   "google-cloud-monitoring",
   "google-cloud-trace",
   "google-cloud-debugger"]
end


task :default => :test
