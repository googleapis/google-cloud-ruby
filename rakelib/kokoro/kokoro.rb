require "bundler/setup"
require "fileutils"
require "json"
require "net/http"
require "open3"

require_relative "command"
require_relative "../devsite/repo_metadata"

class Kokoro < Command
  # Normally true. Set to false temporarily when releases are frozen.
  RELEASE_PLEASE_ENABLED = true

  attr_reader :tag

  def initialize ruby_versions, gems, updated_gems, gem: nil
    @gems          = gems
    @updated_gems  = updated_gems
    @gem           = gem

    @failed         = false
    @tag            = nil
    @updated        = @updated_gems.include? @gem
    @should_release = RELEASE_PLEASE_ENABLED &&
                      ENV.fetch("OS", "") == "linux" &&
                      RUBY_VERSION == ruby_versions.sort.last
    @pr_number      = ENV["KOKORO_GITHUB_PULL_REQUEST_NUMBER"]
  end

  def presubmit
    @updated_gems.each do |gem|
      run_ci gem do
        run "bundle exec rake ci", 1800
      end
    end
  end

  def continuous
    run_ci do
      if @updated
        header "Gem Updated - Running Acceptance"
        run "bundle exec rake ci:acceptance", 3600
      else
        header "Gem Unchanged - Skipping Acceptance"
        run "bundle exec rake ci", 3600
      end
      local_docs_test if should_link_check?
    end
  end

  def cloudrad
    v = version
    run_ci @gem do
      header "Building Cloudrad Docs"
      FileUtils.remove_dir "doc", true
      run "bundle exec rake cloudrad", 1800
      metadata = RepoMetadata.from_source(".repo-metadata.json")
      metadata["version"] = v
      metadata.build "."
      header "Uploading Cloudrad Docs"
      opts = [
        "--credentials=#{ENV['KOKORO_KEYSTORE_DIR']}/73713_docuploader_service_account",
        "--staging-bucket=#{ENV.fetch 'V2_STAGING_BUCKET', 'docs-staging-v2-dev'}",
        "--metadata-file=./docs.metadata",
        "--destination-prefix docfx"
      ]
      run "python3 -m docuploader upload doc #{opts.join ' '}"
    end
  end

  def devsite
    v = version
    run_ci @gem do
      header "Building Devsite Docs"
      FileUtils.remove_dir "doc", true
      run "bundle exec rake yard", 1800
      metadata = RepoMetadata.from_source(".repo-metadata.json")
      metadata["version"] = v
      metadata.build "."
      header "Uploading Devsite Docs"
      opts = [
        "--credentials=#{ENV['KOKORO_KEYSTORE_DIR']}/73713_docuploader_service_account",
        "--staging-bucket=#{ENV.fetch 'STAGING_BUCKET', 'docs-staging'}",
        "--metadata-file=./docs.metadata"
      ]
      run "python3 -m docuploader upload doc #{opts.join ' '}"
    end
  end

  def samples_presubmit
    samples_to_be_tested.each do |gem|
      header "Found changes for #{gem}. Running sample tests"
      run_ci gem do
        run "bundle exec rake samples:master", 3600
      end
    end
  end

  def samples_latest
    unless Dir.entries(@gem).include? "samples"
      return header "No samples for #{@gem}. Exiting"
    end
    run_ci do
      run "bundle exec rake samples:latest", 3600
    end
  end

  def samples_master
    @updated_gems.each do |gem|
      next unless Dir.entries(gem).include? "samples"
      next unless Dir.entries("#{gem}/samples").include? "Rakefile"
      run_ci gem do
        header "Running samples tests for #{gem}"
        run "bundle exec rake samples:master", 1800
      end
    end
  end

  def nightly
    run_ci do
      run "bundle exec rake ci:acceptance", 3600
      local_docs_test if should_link_check?
    end
  end

  def post
    job_info
    git_commit = ENV.fetch "KOKORO_GITHUB_COMMIT", "master"

    markdown_files = Dir.glob "**/*.md"
    broken_markdown_links = check_links markdown_files,
                                        "https://github.com/googleapis/google-cloud-ruby/tree/#{git_commit}",
                                        " --skip '^(?!(\\Wruby.*google|.*google.*\\Wruby|.*cloud\\.google\\.com))'"

    broken_devsite_links = check_links @gems,
                                       "https://googleapis.dev/ruby",
                                       "/latest/ --recurse --skip https:.*github.*"

    puts_broken_links broken_markdown_links
    puts_broken_links broken_devsite_links
  end

  def release
    load_env_vars
    raise "RUBYGEMS_API_TOKEN must be set" if ENV["RUBYGEMS_API_TOKEN"].nil? || ENV["RUBYGEMS_API_TOKEN"].empty?
    @tag = "#{@gem}/v#{version}"
  end

  def all_local_docs_tests only_updated: false
    all_broken_links = {}
    gems = only_updated ? @updated_gems : @gems
    gems.each do |gem|
      run_ci gem, true do
        broken_links = local_docs_test gem
        all_broken_links[gem] = broken_links unless broken_links.empty?
      end
    end
    puts "**** No updated gems to check" if gems.empty?
    all_broken_links.each do |gem, links|
      puts
      puts "**** BROKEN: #{gem} ****"
      links.each { |link| puts "  #{link}" }
    end
  end

  def one_local_docs_test gem
    run_ci gem, true do
      local_docs_test gem
    end
  end

  def exit_status
    @failed ? 1 : 0
  end

  def check_links location_list, base, tail
    broken_links = Hash.new { |h, k| h[k] = [] }
    location_list.each do |location|
      out, err, st = Open3.capture3 "npx linkinator #{base}/#{location}#{tail}"
      puts out
      unless st.to_i.zero?
        @failed = true
        puts err
      end
      checked_links = out.split "\n"
      checked_links.select! { |link| link =~ /^\[\d+\]/ && !link.include?("[200]") }
      unless checked_links.empty?
        @failed = true
        broken_links[location] += checked_links
      end
    end
    broken_links
  end

  def local_docs_test gem = nil
    gem ||= @gem
    run "bundle exec rake yard"
    broken_links = check_links ["doc"], ".", " -r --skip '^https://googleapis.dev/ruby/#{gem}/latest'"
    puts_broken_links broken_links
    broken_links["doc"]
  end

  def should_link_check? gem = nil
    gem ||= @gem
    return false unless gem && @should_release

    gem_search = `gem search #{gem}`
    gem_search.include? gem
  end

  def autorelease_pending?
    net = Net::HTTP.new "api.github.com", 443
    net.use_ssl = true
    response = net.get "/repos/googleapis/google-cloud-ruby/pulls/#{@pr_number}"
    parsed = JSON.parse response.body
    parsed["labels"].any? { |label| label["name"] == "autorelease: pending" }
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

  def job_info gem = nil
    header "Using Ruby - #{RUBY_VERSION}"
    header_2 "Job Type: #{ENV['JOB_TYPE']}"
    header_2 "Package: #{gem || @gem}"
    puts ""
  end

  def load_env_vars
    service_account = "#{ENV['KOKORO_GFILE_DIR']}/service-account.json"
    raise "#{service_account} is not a file" unless File.file? service_account
    ENV["GOOGLE_APPLICATION_CREDENTIALS"] = service_account
    filename = "#{ENV['KOKORO_GFILE_DIR']}/ruby_env_vars.json"
    raise "#{filename} is not a file" unless File.file? filename
    env_vars = JSON.parse File.read(filename)
    env_vars.each { |k, v| ENV[k] = v }
  end

  def puts_broken_links link_hash
    link_hash.each do |location, links|
      puts "#{location} contains the following broken links:"
      links.each { |link| puts "  #{link}" }
      puts ""
    end
  end

  def release_please gem = nil, token = nil
    gem ||= @gem
    token ||= "#{ENV['KOKORO_KEYSTORE_DIR']}/73713_yoshi-automation-github-key"
    opts = {
      "package-name"         => gem,
      "last-package-version" => version(gem),
      "release-type"         => "ruby-yoshi",
      "repo-url"             => "googleapis/google-cloud-ruby",
      "token"                => token,
      "bump-minor-pre-major" => true
    }.map { |k, v|
      v == true ? "--#{k}" : "--#{k}=#{v}"
    }.join(" ")
    header_2 "Running release-please for #{gem}, since #{version gem}"
    run "npx release-please release-pr #{opts}"
  end

  def release_please_all token = nil
    @gems.each do |gem|
      release_please gem, token
    end
  end

  def run_ci gem = nil, local = false
    gem ||= @gem
    job_info gem
    Dir.chdir gem do
      Bundler.with_clean_env do
        run "bundle update"
        load_env_vars unless local
        windows_acceptance_fix unless local
        start_time = Time.now
        yield
        end_time = Time.now
        puts "#{gem} tests took #{(end_time - start_time).to_i} seconds"
      end
    end
  end

  def sample_dirs
    gems.select do |gem|
      Dir.entries(gem).include? "samples"
    end
  end

  # returns a list of every gem where either its sample
  # or its related gems have changed.
  def samples_to_be_tested
    sample_dirs.select do |dir|
      @updated_gems.any? do |gem|
        gem.include? dir
      end
    end
  end

  def version gem = nil
    version = "0.1.0"
    gem ||= @gem
    run_ci gem, true do
      version = `bundle exec gem list`
                .split("\n").select { |line| line.include? gem }
                .first.split("(").last.split(")").first
    end
    version
  end

  def windows_acceptance_fix
    if ENV["OS"] == "windows"
      FileUtils.mkdir_p "acceptance"
      if File.file? "acceptance/data"
        FileUtils.rm_f "acceptance/data"
        run "call mklink /j acceptance\\data ..\\acceptance\\data"
        puts err if st.to_i != 0
      end
    end
  end
end
