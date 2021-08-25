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

  def self.package_from_context
    return ::ENV["RELEASE_PACKAGE"] if ::ENV["RELEASE_PACKAGE"]
    tags = Array(::ENV["KOKORO_GIT_COMMIT"])
    puts "Got #{tags.inspect} from KOKORO_GIT_COMMIT"
    executor = Toys::Utils::Exec.new
    tags += executor.capture(["git", "describe", "--exact-match", "--tags"], err: :null).strip.split
    puts "All tags: #{tags.inspect}"
    tags.each do |tag|
      if tag =~ %r{^([^/]+)/v\d+\.\d+\.\d+$}
        return Regexp.last_match[1]
      end
    end
    nil
  end

  def initialize gem_name,
                 gem_dir: nil,
                 rubygems_api_token: nil,
                 docs_staging_bucket: nil,
                 docs_staging_bucket_v2: nil,
                 docuploader_credentials: nil,
                 dry_run: false,
                 current_version: nil,
                 logger: nil
    raise "Gem name unknown" unless gem_name
    @gem_name = gem_name
    @gem_dir = gem_dir || (File.directory?(gem_name) ? File.expand_path(gem_name) : Dir.getwd)
    @rubygems_api_token = rubygems_api_token || ENV["RUBYGEMS_API_TOKEN"]
    @docs_staging_bucket = docs_staging_bucket || ENV["STAGING_BUCKET"] || "docs-staging"
    @docs_staging_bucket_v2 = docs_staging_bucket_v2 || ENV["V2_STAGING_BUCKET"] || "docs-staging-v2-dev"
    @docuploader_credentials = docuploader_credentials || ENV["DOCUPLOADER_CREDENTIALS"]
    @dry_run = dry_run ? true : false
    @current_rubygems_version = current_version
    @bundle_updated = false
    result_callback = proc { |result| raise "Command failed" unless result.success? }
    @executor = Toys::Utils::Exec.new logger: logger, result_callback: result_callback
  end

  attr_reader :gem_name
  attr_reader :gem_dir
  attr_reader :rubygems_api_token
  attr_reader :docs_staging_bucket
  attr_reader :docs_staging_bucket_v2
  attr_reader :docuploader_credentials

  def dry_run?
    @dry_run
  end

  def needs_gem_publish?
    Gem::Version.new(gem_version) > Gem::Version.new(current_rubygems_version)
  end

  def transform_links
    puts "**** Transforming links for #{gem_name}"
    Dir.chdir gem_dir do
      Dir.glob "*.md" do |filename|
        content = File.read filename
        content.gsub!(/\[([^\]]*)\]\(([^)]*\.md)\)/, "{file:\\2 \\1}")
        File.open(filename, "w") { |file| file << content }
      end
    end
  end

  def publish_gem
    puts "**** Starting publish_gem for #{gem_name}"
    Dir.chdir gem_dir do
      FileUtils.rm_rf "pkg"
      isolate_bundle do
        @executor.exec ["bundle", "exec", "rake", "build"]
      end
      built_gem_path = "pkg/#{gem_name}-#{gem_version}.gem"
      raise "Failed to build #{built_gem_path}" unless File.file? built_gem_path
      if dry_run?
        puts "**** In dry run mode. Skipping gem publish of #{gem_name}"
        return
      end
      response = gems_client.push File.new built_gem_path
      puts response
      raise "Failed to publish gem" unless response.include? "Successfully registered gem:"
    end
  end

  def publish_docs
    puts "**** Starting publish_docs for #{gem_name}"
    Dir.chdir gem_dir do
      FileUtils.rm_rf "doc"
      FileUtils.rm_rf ".yardoc"
      isolate_bundle do
        @executor.exec ["bundle", "exec", "rake", "yard"]
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
          puts "**** No credentials available. Skipping doc upload of #{gem_name}"
          return
        end
        if dry_run?
          puts "**** In dry run mode. Skipping doc upload of #{gem_name}"
          return
        end
        @executor.exec [
          "python3", "-m", "docuploader", "upload", ".",
          "--credentials", docuploader_credentials,
          "--staging-bucket", docs_staging_bucket,
          "--metadata-file", "./docs.metadata",
        ]
      end
    end
  end

  def publish_rad
    puts "**** Starting publish_rad for #{gem_name}"
    Dir.chdir gem_dir do
      unless File.file? ".yardopts-cloudrad"
        puts "**** No .yardopts-cloudrad file present. Skipping rad upload of #{gem_name}"
        return
      end
      FileUtils.rm_rf "doc"
      FileUtils.rm_rf ".yardoc"
      isolate_bundle do
        @executor.exec ["bundle", "exec", "rake", "cloudrad"]
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
          puts "**** No credentials available. Skipping rad upload of #{gem_name}"
          return
        end
        if dry_run?
          puts "**** In dry run mode. Skipping doc upload of #{gem_name}"
          return
        end
        @executor.exec [
          "python3", "-m", "docuploader", "upload", ".",
          "--credentials", docuploader_credentials,
          "--staging-bucket", docs_staging_bucket_v2,
          "--metadata-file", "./docs.metadata",
          "--destination-prefix", "docfx",
        ]
      end
    end
  end

  def current_rubygems_version
    @current_rubygems_version ||= begin
      gems_client.info(gem_name)["version"]
    rescue Gems::NotFound
      "0.0.0"
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
      @executor.capture_proc(func).strip
    end
  end

  def gems_client
    @gems_client ||= begin
      if rubygems_api_token
        Gems.configure do |config|
          config.key = rubygems_api_token
        end
        puts "Configured rubygems api token of length #{rubygems_api_token.length}"
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
