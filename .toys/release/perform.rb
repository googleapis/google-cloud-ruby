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

desc "Performs a gem release"

optional_arg :package
flag :dry_run, default: ENV["RELEASE_DRY_RUN"] == "true"
flag :base_dir, "--base-dir=PATH"
flag :all, "--all=REGEX"
flag :enable_docs
flag :enable_rad
flag :enable_ghpages
flag :force_republish
flag :rubygems_api_token, "--rubygems-api-token=VALUE"
flag :docs_staging_bucket, "--docs-staging-bucket=VALUE"
flag :rad_staging_bucket, "--rad-staging-bucket=VALUE"
flag :docuploader_credentials, "--docuploader-credentials=VALUE"

include :exec, e: true
include :gems

def run
  gem "gems", "~> 1.2"
  require "fileutils"
  require "gems"
  Dir.chdir context_directory
  Dir.chdir base_dir if base_dir
  load_env

  determine_packages.each do |name, version|
    releaser = Performer.new name,
                             last_version: version,
                             logger: logger,
                             rubygems_api_token: rubygems_api_token || ENV["RUBYGEMS_API_TOKEN"],
                             docs_staging_bucket: docs_staging_bucket || ENV["STAGING_BUCKET"] || "docs-staging",
                             rad_staging_bucket: rad_staging_bucket || ENV["V2_STAGING_BUCKET"] || "docs-staging-v2",
                             docuploader_credentials: docuploader_credentials || ENV["DOCUPLOADER_CREDENTIALS"]

    releaser.run force_republish: force_republish,
                 enable_docs: enable_docs,
                 enable_rad: enable_rad,
                 enable_ghpages: enable_ghpages,
                 dry_run: dry_run
  end
end

def load_env
  kokoro_gfile_dir = ENV["KOKORO_GFILE_DIR"]
  return unless kokoro_gfile_dir

  service_account = File.join kokoro_gfile_dir, "service-account.json"
  raise "#{service_account} is not a file" unless File.file? service_account
  ENV["GOOGLE_APPLICATION_CREDENTIALS"] = service_account

  filename = File.join kokoro_gfile_dir, "ruby_env_vars.json"
  raise "#{filename} is not a file" unless File.file? filename
  env_vars = JSON.parse File.read filename
  env_vars.each { |k, v| ENV[k] ||= v }

  ENV["DOCUPLOADER_CREDENTIALS"] ||= File.join kokoro_gfile_dir, "secret_manager", "docuploader_service_account"
end

def determine_packages
  packages = {}
  if all
    current_versions = lookup_current_versions all
    regex = Regexp.new all
    Dir.glob("*/*.gemspec") do |path|
      name = File.dirname path
      packages[name] = cuurent_versions[name] if regex.match? name
    end
  else
    packages[package || package_from_context] = nil
  end
  packages
end

def package_from_context
  return ENV["RELEASE_PACKAGE"] unless ENV["RELEASE_PACKAGE"].to_s.empty?
  tags = Array(ENV["KOKORO_GIT_COMMIT"])
  logger.info "Got #{tags.inspect} from KOKORO_GIT_COMMIT"
  tags += capture(["git", "describe", "--exact-match", "--tags"], err: :null, e: false).strip.split
  logger.info "All tags: #{tags.inspect}"
  tags.each do |tag|
    if tag =~ %r{^([^/]+)/v\d+\.\d+\.\d+$}
      return Regexp.last_match[1]
    end
  end
  logger.error "Unable to determine package from context"
  exit 1
end

def lookup_current_versions regex
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

class Performer
  def initialize gem_name,
                 gem_dir: nil,
                 rubygems_api_token: nil,
                 docs_staging_bucket: nil,
                 rad_staging_bucket: nil,
                 docuploader_credentials: nil,
                 last_version: nil,
                 logger: nil
    @gem_name = gem_name
    @logger = logger
    result_callback = proc { |result| raise "Command failed" unless result.success? }
    @executor = Toys::Utils::Exec.new logger: @logger, result_callback: result_callback
    @gem_dir = gem_dir
    @gem_dir ||= (File.file?("#{@gem_name}/#{@gem_name}.gemspec") ? File.expand_path(@gem_name) : Dir.getwd)
    @rubygems_api_token = rubygems_api_token
    @docs_staging_bucket = docs_staging_bucket
    @rad_staging_bucket = rad_staging_bucket
    @docuploader_credentials = docuploader_credentials
    @dry_run = dry_run ? true : false
    @current_rubygems_version = Gem::Version.new last_version if last_version
    @bundle_updated = false
  end

  attr_reader :gem_name
  attr_reader :gem_dir
  attr_reader :rubygems_api_token
  attr_reader :docs_staging_bucket
  attr_reader :rad_staging_bucket
  attr_reader :docuploader_credentials
  attr_reader :logger

  def needs_gem_publish?
    gem_version > current_rubygems_version
  end

  def run force_republish: false,
          enable_docs: false,
          enable_rad: false
          enable_ghpages: false,
          dry_run: false
    if !force_republish && !needs_gem_publish?
      logger.warn "**** Gem #{gem_name} is already up to date at version #{gem_version}. Skipping."
      return
    end
    transform_links
    publish_gem dry_run: dry_run
    publish_docs dry_run: dry_run if enable_docs
    publish_rad dry_run: dry_run if enable_rad
    publish_ghpages dry_run: dry_run if enable_ghpages
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

  def publish_gem dry_run: false
    logger.info "**** Starting publish_gem for #{gem_name}"
    Dir.chdir gem_dir do
      FileUtils.rm_rf "pkg"
      run_aux_task "build"
      built_gem_path = "pkg/#{gem_name}-#{gem_version}.gem"
      raise "Failed to build #{built_gem_path}" unless File.file? built_gem_path
      unless needs_gem_publish?
        logger.warn "**** Already published. Skipping gem publish of #{gem_name}"
        return
      end
      if dry_run
        logger.warn "**** In dry run mode. Skipping gem publish of #{gem_name}"
        return
      end
      response = gems_client.push File.new built_gem_path
      logger.info response
      raise "Failed to publish gem" unless response.include? "Successfully registered gem:"
    end
  end

  def publish_docs dry_run: false
    logger.info "**** Starting publish_docs for #{gem_name}"
    do_docuploader type: "docs",
                   yardopts_file: ".yardopts",
                   task_name: "yard",
                   staging_bucket: docs_staging_bucket,
                   docuploader_args: [],
                   dry_run: dry_run
  end

  def publish_rad dry_run: false
    logger.info "**** Starting publish_rad for #{gem_name}"
    do_docuploader type: "rad",
                   yardopts_file: ".yardopts-cloudrad",
                   task_name: "cloudrad",
                   staging_bucket: rad_staging_bucket,
                   docuploader_args: ["--destination-prefix", "docfx"],
                   dry_run: dry_run
  end

  def do_docuploader type:, yardopts_file:, task_name:, staging_bucket:, docuploader_args:, dry_run: false
    Dir.chdir gem_dir do
      unless File.file? yardopts_file
        logger.warn "**** No #{yardopts_file} file present. Skipping #{type} upload of #{gem_name}"
        return
      end
      FileUtils.rm_rf "doc"
      FileUtils.rm_rf ".yardoc"
      run_aux_task task_name
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
        if dry_run
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

  def publish_ghpages dry_run: false
    logger.info "**** Starting publish_ghpages for #{gem_name}"
    logger.warn "Not yet implemented"
    # TODO
  end

  def run_aux_task task_name
    if File.file? "Rakefile"
      isolate_bundle do
        @executor.exec ["bundle", "exec", "rake", task_name]
      end
    else
      @executor.exec ["toys", task_name]
    end
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
