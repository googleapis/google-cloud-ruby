require "bundler/setup"
require "fileutils"
require "rake/testtask"
require "rubocop/rake_task"

desc "Runs rubocop at the root level"
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ["-c", ".rubocop_root.yml"]
end

task :bundleupdate do
  each_valid_gem bundleupdate: true, name: "BUNDLE UPDATE"
end

desc "Runs rubocop, jsodoc, and tests for all gems individually."
task :each, :bundleupdate do |t, args|
  each_valid_gem bundleupdate: args[:bundleupdate] do |gem|
    header "#{gem} rubocop", "*"
    run_task_if_exists "rubocop"
    header "#{gem} doctest", "*"
    run_task_if_exists "doctest"
    header "#{gem} test", "*"
    run_task_if_exists "test"
  end
end

# rake task for link_transformer_test
desc "Runs tests for link_transformer class methods"
Rake::TestTask.new do |t|
  t.warning = true
  t.test_files = FileList["test/*_test.rb"]
end

namespace :test do
  desc "Runs tests for all gems individually."
  task :each, :bundleupdate do |t, args|
    each_valid_gem bundleupdate: args[:bundleupdate], name: "RUNNING TESTS" do |gem|
      header "#{gem} test", "*"
      run_task_if_exists "test"
    end
  end

  desc "Runs tests with coverage for all gems."
  task :coverage do
    each_valid_gem bundleupdate: args[:bundleupdate], name: "RUNNING TESTS" do |gem|
      header "#{gem} test", "*"
      run_task_if_exists "test:coverage"
    end
  end

  desc "Runs codecov report for all gems."
  task :codecov do
    abort "**** Codecov disabled ****"
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

  each_valid_gem name: "RUNNING ACCEPTANCE TESTS" do |gem|
    header "#{gem} test", "*"
    run_task_if_exists "acceptance", "#{project},#{keyfile}"
  end
end

namespace :acceptance do
  desc "Runs acceptance tests for all gems individually."
  task :each, :bundleupdate do |t, args|
    each_valid_gem bundleupdate: args[:bundleupdate], name: "RUNNING ACCEPTANCE TESTS" do |gem|
      header "#{gem} test", "*"
      run_task_if_exists "acceptance"
    end
  end

  # Runs each gem's acceptance tests without verifying that a test environment
  # is used. May delete production data! Use only with caution!
  task :unsafe, :bundleupdate do |t, args|
    each_valid_gem bundleupdate: args[:bundleupdate], name: "RUNNING UNSAFE ACCEPTANCE TESTS" do |gem|
      header "UNSAFE ACCEPTANCE TESTS FOR #{gem}"
      sh "bundle exec rake acceptance:run -v"
    end
  end

  desc "Runs acceptance tests with coverage for all gems."
  task :coverage do
    each_valid_gem do |gem|
      header "#{gem} test", "*"
      sh "bundle exec rake acceptance:coverage"
    end
  end

  desc "Runs acceptance:cleanup for all gems."
  task :cleanup, :bundleupdate do |t, args|
    each_valid_gem bundleupdate: args[:bundleupdate] do |gem|
      header "#{gem} cleanup", "*"
      run_task_if_exists "acceptance:cleanup"
    end
  end
end

desc "Runs rubocop report for all gems individually."
task :rubocop_all, :bundleupdate do |t, args|
  each_valid_gem bundleupdate: args[:bundleupdate] do |gem|
    header "RUBOCOP REPORT FOR #{gem}"
    run_task_if_exists "rubocop"
  end
end

require_relative "rakelib/devsite/devsite_builder"

namespace :docs do
  desc "Builds documentation for all gems on current branch (assumes master)"
  task :build_master do
    DevsiteBuilder.new(__dir__).build_master
  end

  desc "Add release and builds documentation for a tag"
  task :publish_tag, [:tag] do |t, args|
    tag = extract_args args, :tag
    DevsiteBuilder.new(__dir__).publish_tag(tag)
  end

  desc "Rebuilds documentation for a tag"
  task :rebuild_tag, [:tag] do |t, args|
    tag = extract_args args, :tag
    DevsiteBuilder.new(__dir__).rebuild_tag(tag)
  end

  desc "Builds documentation for all tags and current branch (assumes master)"
  task :republish_all do
    DevsiteBuilder.new(__dir__).republish_all
  end
end

desc "Runs yard-doctest example tests for all gems individually."
task :doctest, :bundleupdate do |t, args|
  each_valid_gem bundleupdate: args[:bundleupdate] do |gem|
    header "DOCTEST FOR #{gem}"
    run_task_if_exists "doctest"
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

desc "Run the CI build for all gems."
task :ci, :bundleupdate do |t, args|
  each_valid_gem bundleupdate: args[:bundleupdate] do |gem|
    header "CI FOR #{gem}"
    run_task_if_exists "ci"
  end
end

namespace :ci do
  desc "Run the CI build, with acceptance tests, for all gems."
  task :acceptance, :bundleupdate do |t, args|
    each_valid_gem bundleupdate: args[:bundleupdate] do |gem|
      header "CI ACCEPTANCE FOR #{gem}"
      run_task_if_exists "ci:acceptance"
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

  require_relative "rakelib/link_transformer"
  Dir.chdir package do
    Bundler.with_clean_env do
      sh "rm -rf pkg"
      sh "bundle update"
      # transform markdown links to yard links during build
      yard_link_transformer = LinkTransformer.new
      files = yard_link_transformer.find_markdown_files
      yard_link_transformer.transform_links_in_files files
      sh "bundle exec rake build"
    end
  end

  path_to_be_pushed = "#{package}/pkg/#{package}-#{version}.gem"
  gem_was_published = nil
  if File.file? path_to_be_pushed
    begin
      response = ::Gems.push File.new path_to_be_pushed
      puts response
      raise unless response.include? "Successfully registered gem:"
      gem_was_published = true
      puts "Successfully built and pushed #{package} for version #{version}"
    rescue => e
      gem_was_published = false
      raise "Error while releasing #{package} version #{version}: #{e.message}"
    end
  else
    raise "Cannot build #{package} for version #{version}"
  end

  if gem_was_published
    Rake::Task["kokoro:publish_docs"].invoke
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
  desc "Print all the changes in lib since the last release"
  task :lib do
    valid_gems.each do |gem|
      begin
        tag = current_release_tag gem
        stats = (`git diff --stat #{tag}..master #{gem}/lib`).split("\n")
        if stats.empty?
          puts "#{gem}: no changes in lib"
        else
          puts "#{gem}:#{stats.last} (#{oldest_commit_since_release gem, tag})"
        end
      rescue
        puts "#{gem}: not yet released"
      end
    end
  end

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
  each_valid_gem bundleupdate: true, gem_list: gems_with_ext do |gem|
    header "Compile C extension for #{gem}"
    sh "bundle exec rake compile"
  end
end

namespace :kokoro do
  require_relative "rakelib/kokoro/kokoro"
  require "net/http"
  require "uri"

  desc "Generate configs for kokoro"
  task :build do
    puts "kokoro:build no longer needed"
  end

  task :presubmit do
    kokoro.presubmit
    exit kokoro.exit_status
  end

  task :continuous do
    kokoro.continuous
    exit kokoro.exit_status
  end

  task :samples_presubmit do
    kokoro.samples_presubmit
    exit kokoro.exit_status
  end

  task :samples_latest do
    kokoro.samples_latest
    exit kokoro.exit_status
  end

  task :samples_master do
    kokoro.samples_master
    exit kokoro.exit_status
  end

  desc "Runs post-build logic on kokoro."
  task :post do
    kokoro.post
    exit kokoro.exit_status
  end

  task :nightly do
    kokoro.nightly
    exit kokoro.exit_status
  end

  task :release do
    kokoro.release
    Rake::Task["release"].invoke kokoro.tag
  end

  task :release_please, :gem, :token do |t, args|
    if args[:gem] && args[:gem] == "all"
      kokoro.release_please_all args[:token]
    else
      kokoro.release_please args[:gem], args[:token]
    end
  end

  task :publish_docs do
    kokoro.devsite
    # kokoro.cloudrad
    exit kokoro.exit_status
  end

  task :republish do
    kokoro.load_env_vars
    Rake::Task["docs:republish_all"].invoke
  end

  task :all_local_docs_tests do
    kokoro.all_local_docs_tests
    exit kokoro.exit_status
  end

  task :updated_local_docs_tests do
    kokoro.all_local_docs_tests only_updated: true
    exit kokoro.exit_status
  end

  task :one_local_docs_test, [:gem] do |t, args|
    gem = args[:gem]
    kokoro.one_local_docs_test gem
    exit kokoro.exit_status
  end

  def kokoro
    dockerfile_url = "https://raw.githubusercontent.com/googleapis/testing-infra-docker/master/ruby/multi/Dockerfile"
    matches = /ENV RUBY_VERSIONS="([\d\.\s]*)"/.match Net::HTTP.get(URI(dockerfile_url))
    raise "Could not find ruby versions from testing-infra-docker dockerfile" unless matches
    @kokoro ||= Kokoro.new matches[1].split,
                           gems,
                           updated_gems,
                           gem: ENV["PACKAGE"]
  end
end

task :one_local_cloudrad_docs, [:gem] do |t, args|
  gem = args[:gem]
  version = "0.1.0"
  allowed_fields = ["name", "version", "language", "distribution-name", "product-page", "github-repository", "issue-tracker"]
  Dir.chdir gem do
    Bundler.with_clean_env do
      sh "bundle update"
      version = `bundle exec gem list`
                .split("\n").select { |line| line.include? gem }
                .first.split("(").last.split(")").first
    end
  end

  Dir.chdir gem do
    Bundler.with_clean_env do
      sh "bundle update"
      FileUtils.remove_dir "doc", true
      sh "bundle exec rake cloudrad"

      metadata = JSON.parse File.read(".repo-metadata.json")
      metadata.transform_keys! { |k| k.sub "_", "-" }
      metadata["version"] = version
      metadata["name"] = metadata["distribution-name"]
      metadata.delete_if { |k, _| !allowed_fields.include? k }
      fields = metadata.to_a.map { |kv| "--#{kv[0]} #{kv[1]}" }
      sh "python3 -m docuploader create-metadata #{fields.join ' '}"

      gac = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
      ENV.delete "GOOGLE_APPLICATION_CREDENTIALS"
      opts = [
        "--credentials=''",
        "--staging-bucket=#{ENV.fetch 'V2_STAGING_BUCKET', 'docs-staging-v2-dev'}",
        "--metadata-file=./docs.metadata",
        "--destination-prefix docfx"
      ]
      sh "python3 -m docuploader upload doc #{opts.join ' '}"
    end
  end
end

desc "Runs python -m synthtool for each gem containing a synth.py file (see https://github.com/googleapis/synthtool)"
task :synthtool do
  each_valid_gem gem_list: gapic_gems do |gem|
    header "Run `python -m synthtool` for #{gem}"
    sh "python -m synthtool"
  end
end

def gems
  Dir.glob("*/*.gemspec").map { |gem| gem.split("/").first }.sort
end

def updated_gems
  updated_directories = `git --no-pager diff --name-only HEAD^ HEAD | grep "/" | cut -d/ -f1 | sort | uniq || true`
  updated_directories = updated_directories.split("\n")
  valid_gems.select { |gem| updated_directories.include? gem }
end

def valid_gems
  gems.select { |gem|
    spec = Gem::Specification::load("#{gem}/#{gem}.gemspec")
    spec.required_ruby_version.satisfied_by? Gem::Version.new(RUBY_VERSION)
  }
end

def each_valid_gem bundleupdate: false, name: "RUNNING", gem_list: nil
  (gem_list || valid_gems).each do |gem|
    Dir.chdir gem do
      block = proc do
        header "#{name}: #{gem}"
        sh "bundle update" if bundleupdate
        yield gem if block_given?
      end
      if Bundler.respond_to? :with_unbundled_env
        Bundler.with_unbundled_env(&block)
      else
        Bundler.with_clean_env(&block)
      end
    end
  end
end

def gapic_gems
  gems.select { |gem| File.exist? "#{gem}/synth.py" }
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
    sh "bundle exec rake '#{task_name}[#{params}]'"
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
