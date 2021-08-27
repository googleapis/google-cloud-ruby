# frozen_string_literal: true

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fileutils"
require "gems"
require "rubygems"
require "toys/utils/exec"

class Releaser
  @loaded_env = false

  def self.load_env
    return if @loaded_env

    if ::ENV["KOKORO_GFILE_DIR"]
      service_account = "#{::ENV['KOKORO_GFILE_DIR']}/service-account.json"
      raise "#{service_account} is not a file" unless ::File.file? service_account
      ::ENV["GOOGLE_APPLICATION_CREDENTIALS"] = service_account

      filename = "#{::ENV['KOKORO_GFILE_DIR']}/ruby_env_vars.json"
      raise "#{filename} is not a file" unless ::File.file? filename
      env_vars = ::JSON.parse ::File.read filename
      env_vars.each { |k, v| ::ENV[k] ||= v }

      ::ENV["DOCUPLOADER_CREDENTIALS"] ||= ::File.join ::ENV["KOKORO_GFILE_DIR"],
                                                       "secret_manager", "docuploader_service_account"
    end

    @loaded_env = true
  end

  def self.lookup_current_versions regex
    versions = {}
    lines = `gem search '^#{regex}'`.split("\n")
    lines.each do |line|
      if line =~ /^(#{regex}) \(([\d.]+)\)/
        versions[Regexp.last_match[1]] = Regexp.last_match[2]
      end
    end
    raise "Something went wrong getting all current gem versions" if versions.empty?
    versions
  end

  def initialize gem_name: nil,
                 gem_dir: nil,
                 rubygems_api_token: nil,
                 docs_staging_bucket: nil,
                 docs_staging_bucket_v2: nil,
                 docuploader_credentials: nil,
                 dry_run: false,
                 last_version: nil,
                 logger: nil,
                 enable_docs: false,
                 enable_rad: false,
                 enable_ghpages: false
    @logger = logger
    result_callback = proc { |result| raise "Command failed" unless result.success? }
    @executor = Toys::Utils::Exec.new logger: @logger, result_callback: result_callback

    @gem_name = gem_name || package_from_context
    raise "Unable to determine gem name" unless @gem_name
    @gem_dir = gem_dir || (File.directory?(@gem_name) ? File.expand_path(@gem_name) : Dir.getwd)
    @rubygems_api_token = rubygems_api_token || ENV["RUBYGEMS_API_TOKEN"]
    @docs_staging_bucket = docs_staging_bucket || ENV["STAGING_BUCKET"] || "docs-staging"
    @docs_staging_bucket_v2 = docs_staging_bucket_v2 || ENV["V2_STAGING_BUCKET"] || "docs-staging-v2-dev"
    @docuploader_credentials = docuploader_credentials || ENV["DOCUPLOADER_CREDENTIALS"]
    @dry_run = dry_run ? true : false
    @current_rubygems_version = Gem::Version.new last_version if last_version
    @bundle_updated = false
    @enable_docs = enable_docs
    @enable_rad = enable_rad
    @enable_ghpages = enable_ghpages
  end

  attr_reader :gem_name
  attr_reader :gem_dir
  attr_reader :rubygems_api_token
  attr_reader :docs_staging_bucket
  attr_reader :docs_staging_bucket_v2
  attr_reader :docuploader_credentials
  attr_reader :logger

  def dry_run?
    @dry_run
  end

  def enable_docs?
    @enable_docs
  end

  def enable_rad?
    @enable_rad
  end

  def enable_ghpages?
    @enable_ghpages
  end

  def run
    transform_links
    publish_gem
    publish_docs if enable_docs?
    publish_rad if enable_rad?
    publish_ghpages if enable_ghpages?
  end

  def package_from_context
    return ::ENV["RELEASE_PACKAGE"] if ::ENV["RELEASE_PACKAGE"]
    tags = Array(::ENV["KOKORO_GIT_COMMIT"])
    logger.info "Got #{tags.inspect} from KOKORO_GIT_COMMIT"
    tags += @executor.capture(["git", "describe", "--exact-match", "--tags"],
                              err: :null, result_callback: nil).strip.split
    logger.info "All tags: #{tags.inspect}"
    tags.each do |tag|
      if tag =~ %r{^([^/]+)/v\d+\.\d+\.\d+$}
        return Regexp.last_match[1]
      end
    end
    nil
  end

  def transform_links
    logger.info "**** Transforming links for #{gem_name}"
    Dir.chdir gem_dir do
      Dir.glob "*.md" do |filename|
        content = File.read filename
        content.gsub!(/\[([^\]]*)\]\(([^):]*\.md)\)/, "{file:\\2 \\1}")
        File.open(filename, "w") { |file| file << content }
      end
    end
  end

  def publish_gem
    logger.info "**** Starting publish_gem for #{gem_name}"
    Dir.chdir gem_dir do
      FileUtils.rm_rf "pkg"
      isolate_bundle do
        @executor.exec ["bundle", "exec", "rake", "build"]
      end
      built_gem_path = "pkg/#{gem_name}-#{gem_version}.gem"
      raise "Failed to build #{built_gem_path}" unless File.file? built_gem_path
      if gem_version <= current_rubygems_version
        logger.warn "**** Already published. Skipping gem publish of #{gem_name}"
        return
      end
      if dry_run?
        logger.warn "**** In dry run mode. Skipping gem publish of #{gem_name}"
        return
      end
      response = gems_client.push File.new built_gem_path
      logger.info response
      raise "Failed to publish gem" unless response.include? "Successfully registered gem:"
    end
  end

  def publish_docs
    logger.info "**** Starting publish_docs for #{gem_name}"
    do_docuploader "docs", ".yardopts", "yard", docs_staging_bucket, []
  end

  def publish_rad
    logger.info "**** Starting publish_rad for #{gem_name}"
    do_docuploader "rad", ".yardopts-cloudrad", "cloudrad", docs_staging_bucket_v2, ["--destination-prefix", "docfx"]
  end

  def do_docuploader type, yardopts_file, rake_task, staging_bucket, docuploader_args
    Dir.chdir gem_dir do
      unless File.file? yardopts_file
        logger.warn "**** No #{yardopts_file} file present. Skipping #{type} upload of #{gem_name}"
        return
      end
      FileUtils.rm_rf "doc"
      FileUtils.rm_rf ".yardoc"
      isolate_bundle do
        @executor.exec ["bundle", "exec", "rake", rake_task]
      end
      Dir.chdir "doc" do
        @executor.exec [
          "python3", "-m", "docuploader", "create-metadata",
          "--name", gem_name,
          "--distribution-name", gem_name,
          "--language", "ruby",
          "--version", "v#{gem_version}",
        ]
        unless docuploader_credentials
          logger.warn "**** No credentials available. Skipping #{type} upload of #{gem_name}"
          return
        end
        if dry_run?
          logger.warn "**** In dry run mode. Skipping #{type} upload of #{gem_name}"
          return
        end
        docuploader_cmd = [
          "python3", "-m", "docuploader", "upload", ".",
          "--credentials", docuploader_credentials,
          "--staging-bucket", staging_bucket,
          "--metadata-file", "./docs.metadata",
        ] + docuploader_args
        @executor.exec docuploader_cmd
      end
    end
  end

  def publish_ghpages
    logger.info "**** Starting publish_ghpages for #{gem_name}"
    logger.warn "Not yet implemented"
    # TODO
  end

  def current_rubygems_version
    @current_rubygems_version ||= begin
      value = gems_client.info(gem_name)["version"]
      logger.info "Existing gem version = #{value}"
      Gem::Version.new value
    rescue Gems::NotFound
      logger.info "No existing gem version"
      Gem::Version.new "0.0.0"
    end
  end

  def gem_version
    @gem_version ||= begin
      func = proc do
        Dir.chdir gem_dir do
          spec = Gem::Specification.load "#{gem_name}.gemspec"
          puts spec.version
        end
      end
      value = @executor.capture_proc(func).strip
      logger.info "Specification gem version = #{value}"
      Gem::Version.new value
    end
  end

  def gems_client
    @gems_client ||= begin
      if rubygems_api_token
        Gems.configure do |config|
          config.key = rubygems_api_token
        end
        logger.info "Configured rubygems api token of length #{rubygems_api_token.length}"
      end
      Gems::Client.new
    end
  end

  def isolate_bundle
    block = proc do
      @executor.exec ["bundle", "update"] unless @bundle_updated
      @bundle_updated = true
      yield
    end
    if defined?(Bundler)
      if Bundler.respond_to? :with_unbundled_env
        Bundler.with_unbundled_env(&block)
      else
        Bundler.with_clean_env(&block)
      end
    else
      block.call
    end
  end
end
