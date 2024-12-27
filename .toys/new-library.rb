# frozen_string_literal: true

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

desc "A tool that generates a new client library"

required_arg :proto_namespace

flag :piper_client, "--piper-client=NAME" do
  desc "Name of the piper client"
end
flag :protos_path, "--protos-path=PATH" do
  desc "Path to the googleapis protos repo or third_party directory"
end
flag :source_path, "--source-path=PATH" do
  desc "Path to the googleapis-gen source repo"
end
flag :pull_googleapis, "--pull-googleapis[=COMMIT]" do
  desc "Generate by pulling googleapis/googleapis and running Bazel from the protos there"
end
flag :pull, "--[no-]pull" do
  desc "Pull the latest owlbot images before running"
end
flag :interactive, "--[no-]interactive", "-i" do
  desc "Run in interactive mode, including editing of the .owlbot.rb file"
end
flag :editor do
  default ENV["EDITOR"]
  desc "The path to your editor. Uses the EDITOR environment variable by default."
end
flag :branch_name, "--branch NAME" do
  desc "The name of the branch to use if opening a pull request. Defaults to gen/GEM-NAME."
end
flag :git_remote, "--remote NAME" do
  desc "The name of the git remote to use as the pull request head. If omitted, does not open a pull request."
end
flag :enable_fork, "--fork" do
  desc "Use a fork to open the pull request"
end
flag :enable_tests, "--[no-]test" do
  desc "Run CI on the newly-created library"
end
flag :bootstrap_releases, "--[no-]bootstrap-releases" do
  desc "Also add release-please configuration for the newly-created library"
end
flag :enable_bazelisk, "--bazelisk" do
  desc "Enable running bazel commands with bazelisk"
end

static :config_name, "release-please-config.json"
static :manifest_name, ".release-please-manifest.json"

include :exec, e: true
include :fileutils
include :terminal
include :git_cache
include "yoshi-pr-generator"

def run
  setup
  set :branch_name, "gen/#{gem_name}" unless branch_name
  commit_message = "feat: Initial generation of #{gem_name}"
  yoshi_pr_generator.capture enabled: !git_remote.nil?,
                             remote: git_remote,
                             branch_name: branch_name,
                             commit_message: commit_message do
    write_owlbot_config
    write_owlbot_script
    call_owlbot
    create_release_please_configs if bootstrap_releases
    test_library if enable_tests
  end
end

def setup
  require "erb"

  Dir.chdir context_directory
  error "#{owlbot_config_path} already exists" if File.file? owlbot_config_path
  yoshi_utils.git_ensure_identity
  if enable_fork
    set :git_remote, "pull-request-fork" unless git_remote
    yoshi_utils.gh_ensure_fork remote: git_remote
  end
  mkdir_p gem_name
end

def ensure_docker
  result = exec ["docker", "--version"], out: :capture, e: false
  error "Docker not installed" unless result.success?
  logger.info "Verified docker present"
end

def write_owlbot_config
  template = File.read find_data "owlbot-config-template.erb"
  File.write owlbot_config_path, ERB.new(template).result(binding)
end

def write_owlbot_script
  return unless interactive
  error "No EDITOR set" unless editor
  template = File.read find_data "owlbot-script-template.erb"
  File.write owlbot_script_path, ERB.new(template).result(binding)
  exec [editor, owlbot_script_path]
  new_content = File.read owlbot_script_path
  error "Aborted" if new_content.to_s.strip.empty?
  lines = new_content.split "\n"
  return unless lines.all? { |line| line.strip.empty? || line.start_with?("#") || line.strip == "OwlBot.move_files" }
  puts "Omitting .owlbot.rb"
  rm owlbot_script_path
end

def call_owlbot
  cmd = ["owlbot", gem_name]
  cmd << "--pull" if pull
  cmd << "--protos-path" << protos_path if protos_path
  cmd << "--source-path" << source_path if source_path
  cmd << "--piper-client" << piper_client if piper_client
  if pull_googleapis == true
    cmd << "--pull-googleapis"
  elsif pull_googleapis
    cmd << "--pull-googleapis=#{pull_googleapis}"
  end
  cmd << "--bazelisk" if enable_bazelisk
  cmd += verbosity_flags
  exec_tool cmd
end

def create_release_please_configs
  manifest = JSON.parse File.read manifest_name
  manifest[gem_name] = "0.0.1"
  manifest = add_fillers(manifest).sort.to_h
  File.write manifest_name, "#{JSON.pretty_generate manifest}\n"

  config = JSON.parse File.read config_name
  config["packages"][gem_name] = {
    "component" => gem_name,
    "version_file" => gem_version_file,
  }
  config["packages"] = config["packages"].sort.to_h
  File.write config_name, "#{JSON.pretty_generate config}\n"
end

def gem_version_file
  @gem_version_file ||= begin
    version_path = gem_name.tr "-", "/"
    version_file = File.join "lib", version_path, "version.rb"
    version_file_full = File.join gem_name, version_file
    raise "Unable to find #{version_file_full}" unless File.file? version_file_full
    version_file
  end
  @gem_version_file
end

def add_fillers manifest
  non_filler_keys = manifest.keys.filter { |k| !k.end_with? "+FILLER" }
  non_filler_keys.each do |key|
    manifest["#{key}+FILLER"] = "0.0.0"
  end
  manifest
end

def test_library
  Dir.chdir gem_name do
    exec ["bundle", "install"]
    exec ["toys", "ci", "--rubocop", "--yard", "--test"]
  end
end

def owlbot_config_path
  File.join gem_name, ".OwlBot.yaml"
end

def owlbot_script_path
  File.join gem_name, ".owlbot.rb"
end

def bazel_base_dir
  @bazel_base_dir ||=
    if piper_client
      piper_client_dir = capture(["p4", "g4d", piper_client]).strip
      File.join piper_client_dir, "third_party", "googleapis", "stable"
    elsif protos_path
      File.expand_path protos_path
    else
      git_cache.find "https://github.com/googleapis/googleapis.git", update: true
    end
end

def gem_name
  @gem_name ||= begin
    build_file_path = File.join bazel_base_dir, proto_namespace, "BUILD.bazel"
    bazel_rules_content = File.read build_file_path
    if bazel_rules_content =~ /"ruby-cloud-gem-name=([\w-]+)"/
      Regexp.last_match[1]
    else
      error "Unable to find gem name rule in #{build_file_path}"
    end
  end
end

def copyright_year
  Time.now.year
end

def error *messages
  messages.each do |message|
    puts message, :red, :bold
  end
  exit 1
end
