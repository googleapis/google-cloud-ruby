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
flag :pull do
  desc "Pull the latest owlbot images before running"
end
flag :interactive, "--interactive", "-i" do
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
flag :enable_tests, "--test" do
  desc "Run CI on the newly-created library"
end

include :exec, e: true
include :fileutils
include :terminal
include :git_cache

def run
  setup
  generate_pull_request gem_name: gem_name,
                        git_remote: git_remote,
                        branch_name: branch_name || "gen/#{gem_name}",
                        commit_message: "feat: Initial generation of #{gem_name}" do
    write_owlbot_config
    write_owlbot_script
    call_owlbot
    test_library if enable_tests
  end
end

def setup
  require "erb"
  require "pull_request_generator"
  extend PullRequestGenerator
  ensure_docker

  Dir.chdir context_directory
  error "#{owlbot_config_path} already exists" if File.file? owlbot_config_path
  mkdir_p gem_name
end

def ensure_docker
  result = exec ["docker", "--version"], out: :capture, e: false
  error "Docker not installed" unless result.success?
  logger.info "Verified docker present"
end

def write_owlbot_config
  template = File.read find_data "owlbot-config-template.erb"
  File.open owlbot_config_path, "w" do |file|
    file.write ERB.new(template).result(binding)
  end
end

def write_owlbot_script
  return unless interactive
  error "No EDITOR set" unless editor
  template = File.read find_data "owlbot-script-template.erb"
  File.open owlbot_script_path, "w" do |file|
    file.write ERB.new(template).result(binding)
  end
  exec [editor, owlbot_script_path]
  new_content = File.read owlbot_script_path
  error "Aborted" if new_content.to_s.strip.empty?
  lines = new_content.split("\n")
  if lines.all? { |line| line.strip.empty? || line.start_with?("#") || line.strip == "OwlBot.move_files" }
    puts "Omitting .owlbot.rb"
    rm owlbot_script_path
  end
end

def call_owlbot
  cmd = ["owlbot", gem_name]
  cmd << "--pull" if pull
  cmd << "-#{'v' * verbosity}" if verbosity > 0
  cmd << "-#{'q' * (-verbosity)}" if verbosity < 0
  cmd << "--protos-path" << protos_path if protos_path
  cmd << "--source-path" << source_path if source_path
  cmd << "--piper-client" << piper_client if piper_client
  exec_tool cmd
end

def test_library
  Dir.chdir gem_name do
    exec ["bundle", "install"]
    exec ["bundle", "exec", "rake", "ci"]
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
    if bazel_rules_content =~ /"ruby-cloud-gem-name=([\w-]+)",/
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
