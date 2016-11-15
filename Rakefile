require "bundler/setup"
require "open3"
require "json"

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
task :test do
  require "active_support/all"
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
          sh "bundle exec rake acceptance -v"
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
  desc "Clones gh-pages branch to a temp dir"
  task :clone_gh_pages, [:gh_pages_dir] do |t, args|
    gh_pages_dir = extract_args args, :gh_pages_dir
    gh_pages = gh_pages_path gh_pages_dir
    header "Cloning gh-pages branch to #{gh_pages}"

    FileUtils.remove_dir gh_pages if Dir.exists? gh_pages
    FileUtils.mkdir_p gh_pages

    # checkout the gh-pages branch
    puts "git clone --quiet --branch=gh-pages --single-branch #{git_repo} #{gh_pages} > /dev/null"
    puts `git clone --quiet --branch=gh-pages --single-branch #{git_repo} #{gh_pages} > /dev/null`
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

    unless Dir.exist? gh_pages + "json/google-cloud/#{version}/google/cloud/"
      mkdir_p gh_pages + "json/google-cloud/#{version}/google/cloud/"
    end

    excluded = ["gcloud", "google-cloud", "stackdriver"]
    gems.each do |gem|
      next if excluded.include? gem

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

      unless gem == "google-cloud-core" # There is no `core` subdir, copy files from google/cloud/
        # Copy the contents of subdir for the gem namespace.
        rm_rf gh_pages + "json/google-cloud/#{version}/google/cloud/#{gem_shortname}", verbose: true
        cp_r "#{src}/google/cloud/#{gem_shortname}",
             gh_pages + "json/google-cloud/#{version}/google/cloud/#{gem_shortname}",
             verbose: true
      end
      # Copy the contents of google/cloud/ for the gem. This also gets the core error files.
      cp Dir["#{src}/google/cloud/*.json"], gh_pages + "json/google-cloud/#{version}/google/cloud/", verbose: true
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

    unless Dir.exist? gh_pages + "json/stackdriver/#{version}/google/cloud"
      mkdir_p gh_pages + "json/stackdriver/#{version}/google/cloud", verbose: true
    end

    stackdriver_gems = ["google-cloud-logging", "google-cloud-error_reporting", "google-cloud-monitoring"]
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

    stackdriver_gems = ["stackdriver", "google-cloud-logging", "google-cloud-error_reporting", "google-cloud-monitoring"]
    if stackdriver_gems.include? gem
      stackdriver_version = manifest_versions["stackdriver"]
      header "Assembling jsondoc for stackdriver package"
      puts "Latest stackdriver package version is '#{stackdriver_version}' (from docs/manifest.json)"
      Rake::Task["jsondoc:stackdriver"].invoke(stackdriver_version, gh_pages_dir)
    end

    Rake::Task["jsondoc:publish"].invoke(tag, gh_pages_dir)
  end

  # TODO: Use checkout of tag repo, below, in jsondoc:package, then delete.
  # desc "[Deprecated] Publishes the jsondoc for the tag to the gh-pages branch"
  # task :tag, :tag do |t, args|
  #   tag = args[:tag]
  #   fail "Missing required parameter 'tag'." if tag.nil?
  #
  #   fail "'tag' must be in the format <gem>/<version>" unless tag.include?("/")
  #   gem_name, version =  tag.split("/")
  #
  #
  #   # Verify the tag exists
  #   tag_check = `git show-ref --tags | grep #{tag}`.chomp
  #   if tag_check.empty?
  #     fail "Cannot find the tag '#{tag}'."
  #   end
  #
  #   git_repo = "git@github.com:GoogleCloudPlatform/google-cloud-ruby.git"
  #   if ENV["GH_OAUTH_TOKEN"]
  #     git_repo = "https://#{ENV["GH_OAUTH_TOKEN"]}@github.com/#{ENV["GH_OWNER"]}/#{ENV["GH_PROJECT_NAME"]}"
  #   end
  #
  #   tag_repo  =  Pathname.new(Dir.home) + "tmp/#{tag}-repo"
  #   FileUtils.remove_dir tag_repo if Dir.exists? tag_repo
  #   FileUtils.mkdir_p tag_repo
  #
  #   header "Cloning tag #{tag} to #{tag_repo}"
  #
  #   # checkout the tag repo
  #   puts "git clone --quiet --branch=#{tag} --single-branch #{git_repo} #{tag_repo} > /dev/null"
  #   puts `git clone --quiet --branch=#{tag} --single-branch #{git_repo} #{tag_repo} > /dev/null`
  #   # build the docs in the gem dir in the tag repo
  #   Dir.chdir tag_repo + gem_name do
  #     Bundler.with_clean_env do
  #       # create the docs
  #       puts "bundle install --path .bundle"
  #       puts `bundle install --path .bundle`
  #       puts "bundle exec rake jsondoc"
  #       puts `bundle exec rake jsondoc`
  #     end
  #   end
  #
  # end
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

    gems.each do |gem|
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
      # Decrypt the keyfile
      `openssl aes-256-cbc -K $encrypted_629ec55f39b2_key -iv $encrypted_629ec55f39b2_iv -in keyfile.json.enc -out keyfile.json -d`
      run_acceptance = true
    end

    gems.each do |gem|
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

    gems.each do |gem|
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
  gems.each do |gem|
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
    gems.each do |gem|
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
      # If project_uri not given, default to "http://[project_id].appspot.com"
      project_uri = args[:project_uri] ||
                    "http://#{project_id}.appspot-preview.com"

      fail "You must provide a project_uri. e.g. rake " \
        "integration:gae[http://my-project.appspot.com]" if project_uri.nil?

      test_apps = Dir.glob("integration/*_app").select {|f| File.directory? f}

      test_apps.each do |test_app|
        header "Deploying #{test_app} to GAE Flex"
        deploy_gae_flex test_app do
          gems.each do |gem|
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

    if executable_exists?("gcloud")&& executable_exists?("kubectl")
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
              gems.each do |gem|
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
    else
      header "Unable to find gcloud SDK and Kubernetes CTL. Skip tests. Please reference https://cloud.google.com/sdk/ on installing gcloud SDK and kubernetes CTL."
    end
  end
end

def gems
  `git ls-files -- */*.gemspec`.split("\n").map { |gem| gem.split("/").first }.sort
end

def header str, token = "#"
  line_length = str.length + 8
  puts ""
  puts token * line_length
  puts "#{token * 3} #{str} #{token * 3}"
  puts token * line_length
  puts ""
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

task :default => :test
