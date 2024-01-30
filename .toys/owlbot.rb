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

desc "Runs OwlBot for one or more gems."

long_desc \
  "Runs OwlBot for one or more gems.",
  "",
  "Gems are chosen as follows:",
  "* If one or more gem names are provided on the command line, they are selected.",
  "* Otherwise, if the --all flag is given, all gems covered by OwlBot are selected.",
  "* Otherwise, if run from a gem subdirectory, that gem is selected.",
  "* Otherwise, an error is raised."

remaining_args :gem_names do
  desc "The gems for which to run owlbot."
end
flag :all, "--all[=WHICH]" do
  desc "Run owlbot on all gems in this repo. Optional value can be 'gapics' or 'wrappers'"
end
flag :except, "--except=GEM", handler: :push, default: [] do
  desc "Omit this gem from --all. Can be used multiple times."
end
flag :postprocessor_tag, "--postprocessor-tag=TAG", default: "latest" do
  desc "The tag for the Ruby postprocessor image. Defaults to 'latest'."
end
flag :owlbot_cli_tag, "--owlbot-cli-tag=TAG", default: "latest" do
  desc "The tag for the OwlBot CLI image. Defaults to 'latest'."
end
flag :pull do
  desc "Pull the latest images before running"
end
flag :git_remote, "--remote=NAME" do
  desc "The name of the git remote to use as the pull request head. If omitted, does not open a pull request."
end
flag :enable_fork, "--fork" do
  desc "Use a fork to open the pull request"
end
flag :commit_message, "--message=MESSAGE" do
  desc "The conventional commit message"
end
at_most_one desc: "Source" do
  long_desc \
    "Specify where the generated client comes from.",
    "At most one of these flags can be set. If none is given, the googleapis-gen repo is cloned."
  flag :googleapis_gen_github_token, "--googleapis-gen-github-token=TOKEN" do
    default(ENV["GOOGLEAPIS_GEN_GITHUB_TOKEN"] || ENV["GITHUB_TOKEN"])
    desc "GitHub token for cloning the googleapis-gen repository."
  end
  flag :source_path, "--source-path=PATH" do
    desc "Path to the googleapis-gen source repo."
  end
  flag :protos_path, "--protos-path=PATH" do
    desc "Generate by running Bazel from the given path to the googleapis protos repo or third_party directory."
  end
  flag :piper_client, "--piper-client=NAME" do
    desc "Generate by running Bazel from the given piper client"
  end
end
flag :combined_prs do
  desc "Combine all changes into a single pull request"
end
flag :enable_tests, "--test" do
  desc "Run CI on each library"
end

OWLBOT_CONFIG_FILE_NAME = ".OwlBot.yaml"
OWLBOT_CLI_IMAGE = "gcr.io/cloud-devrel-public-resources/owlbot-cli"
POSTPROCESSOR_IMAGE = "gcr.io/cloud-devrel-public-resources/owlbot-ruby"
STAGING_DIR_NAME = "owl-bot-staging"
TMP_DIR_NAME = "tmp"

include :exec, e: true
include :terminal
include :fileutils
include "yoshi-pr-generator"

def run
  require "psych"
  require "fileutils"
  require "tmpdir"

  gems = choose_gems
  cd context_directory
  setup_git
  gem_info = collect_gem_info gems

  pull_images
  if piper_client || protos_path
    set :source_path, run_bazel(gem_info)
  else
    set :source_path, source_path ? File.expand_path(source_path) : googleapis_gen_path
  end
  run_owlbot gem_info, use_bazel_bin: piper_client || protos_path
  verify_staging gems
  results = process_gems gems
  final_output results
end

def setup_git
  yoshi_utils.git_ensure_identity
  return unless enable_fork
  set :git_remote, "pull-request-fork" unless git_remote
  yoshi_utils.gh_ensure_fork remote: git_remote
end

def ensure_docker
  result = exec ["docker", "--version"], out: :capture, e: false
  error "Docker not installed" unless result.success?
  logger.info "Verified docker present"
end

def choose_gems
  gems = gem_names
  gems = all_gems || gems_from_subdirectory if gems.empty?
  error "You must specify at least one gem name" if gems.empty?
  logger.info "Gems: #{gems}"
  gems
end

def gems_from_subdirectory
  curwd = Dir.getwd
  return [] if context_directory == curwd
  error "unexpected current directory #{curwd}" unless curwd.start_with? context_directory
  Array(curwd.sub("#{context_directory}/", "").split("/").first)
end

def all_gems
  return nil unless all
  cd context_directory do
    gems = Dir.glob("*/#{OWLBOT_CONFIG_FILE_NAME}").map { |path| File.dirname path }
    gems.delete_if do |name|
      !File.file? File.join(context_directory, name, "#{name}.gemspec")
    end
    if all.to_s.start_with? "gapic"
      gems.delete_if { |name| name !~ /-v\d+\w*$/ }
    elsif all.to_s.start_with? "wrapper"
      gems.delete_if { |name| name =~ /-v\d+\w*$/ }
    end
    gems - except
  end
end

def pull_images
  return unless pull
  exec ["docker", "pull", "#{OWLBOT_CLI_IMAGE}:#{owlbot_cli_tag}"]
  exec ["docker", "pull", "#{POSTPROCESSOR_IMAGE}:#{postprocessor_tag}"]
end

def collect_gem_info gems
  gem_info = {}
  gems.each do |name|
    deep_copy_regexes = load_deep_copy_regexes name
    gem_info[name] = { deep_copy_regexes: deep_copy_regexes }
    next unless piper_client || protos_path
    library_paths = deep_copy_regexes.map { |dcr| extract_library_path dcr["source"] }.uniq
    bazel_targets = {}
    library_paths.each do |library_path|
      bazel_targets[library_path] = determine_bazel_target library_path
    end
    gem_info[name][:bazel_targets] = bazel_targets
  end
  gem_info
end

def load_deep_copy_regexes name
  config_path = File.join name, OWLBOT_CONFIG_FILE_NAME
  error "Gem #{name} has no #{OWLBOT_CONFIG_FILE_NAME}" unless File.file? config_path
  config = Psych.load_file config_path
  config["deep-copy-regex"]
end

def extract_library_path source_regex
  separator = "/[^/]+-ruby/"
  error "Unexpected source: #{source_regex}" unless source_regex.include? separator
  source_regex.split(separator).first.sub(%r{^/}, "")
end

def determine_bazel_target library_path
  build_file_path = File.join bazel_base_dir, library_path, "BUILD.bazel"
  error "Unable to find #{build_file_path}" unless File.file? build_file_path
  build_content = File.read build_file_path
  match = /ruby_gapic_assembly_pkg\(\n\s+name\s*=\s*"([\w-]+-ruby)",/.match build_content
  error "Unable to find ruby build rule in #{build_file_path}" unless match
  match[1]
end

def run_bazel gem_info
  gem_info.each_value do |info|
    info[:bazel_targets].each do |library_path, bazel_target|
      exec ["bazel", "build", "//#{library_path}:#{bazel_target}"], chdir: bazel_base_dir
    end
  end
  temp_dir = Dir.mktmpdir
  at_exit { FileUtils.rm_rf temp_dir }
  results_dir = File.join temp_dir, "bazel-bin"
  cp_r File.join(bazel_base_dir, "bazel-bin"), results_dir
  results_dir
end

def googleapis_gen_path
  temp_dir = Dir.mktmpdir
  at_exit { FileUtils.rm_rf temp_dir }
  cd temp_dir do
    exec ["git", "init"]
    token = googleapis_gen_github_token || yoshi_utils.gh_cur_token
    error "No github token found to load googleapis-gen" unless token
    username = yoshi_utils.gh_with_token(token) { yoshi_utils.gh_username }
    add_origin_cmd = ["git", "remote", "add", "origin",
                      "https://#{username}:#{token}@github.com/googleapis/googleapis-gen.git"]
    add_origin_log = ["git", "remote", "add", "origin",
                      "https://xxxxxxxx@github.com/googleapis/googleapis-gen.git"]
    exec add_origin_cmd, log_cmd: "exec: #{add_origin_log.inspect}"
    yoshi_utils.gh_without_standard_git_auth do
      exec ["git", "fetch", "--depth=1", "origin", "HEAD"]
    end
    exec ["git", "branch", "github-head", "FETCH_HEAD"]
    exec ["git", "switch", "github-head"]
  end
  temp_dir
end

def run_owlbot gem_info, use_bazel_bin:
  mkdir_p TMP_DIR_NAME
  temp_config = File.join TMP_DIR_NAME, OWLBOT_CONFIG_FILE_NAME
  rm_f temp_config
  combined_deep_copy_regex = gem_info.values.map { |info| info[:deep_copy_regexes] }.flatten
  combined_config = { "deep-copy-regex" => combined_deep_copy_regex }
  File.open temp_config, "w" do |file|
    file.puts Psych.dump combined_config
  end
  cmd = [
    "-v", "#{source_path}:/source-path",
    "#{OWLBOT_CLI_IMAGE}:#{owlbot_cli_tag}",
    (use_bazel_bin ? "copy-bazel-bin" : "copy-code"),
    "--config-file", temp_config,
    (use_bazel_bin ? "--source-dir" : "--source-repo"), "/source-path"
  ]
  docker_run(*cmd)
  rm_f ".gitconfig"
end

def verify_staging gems
  gems.each do |name|
    staging_dir = File.join STAGING_DIR_NAME, name
    error "Gem #{name} did not output a staging directory" unless File.directory? staging_dir
    error "Gem #{name} staging directory is empty" if Dir.empty? staging_dir
  end
end

def process_gems gems
  temp_staging_dir = File.join TMP_DIR_NAME, STAGING_DIR_NAME
  rm_rf temp_staging_dir
  mv STAGING_DIR_NAME, temp_staging_dir
  if combined_prs
    process_gems_combined_pr gems, temp_staging_dir
  else
    process_gems_separate_prs gems, temp_staging_dir
  end
end

def process_gems_separate_prs gems, temp_staging_dir
  results = {}
  gems.each_with_index do |name, index|
    timestamp = Time.now.utc.strftime "%Y%m%d-%H%M%S"
    branch_name = "owlbot/#{name}-#{timestamp}"
    message = build_commit_message name
    result = yoshi_pr_generator.capture enabled: !git_remote.nil?,
                                        remote: git_remote,
                                        branch_name: branch_name,
                                        commit_message: message do
      process_single_gem name, temp_staging_dir
    end
    puts "Results for #{name} (#{index}/#{gems.size})..."
    results[name] = output_result name, result, :bold
  end
  results
end

def process_gems_combined_pr gems, temp_staging_dir
  timestamp = Time.now.utc.strftime "%Y%m%d-%H%M%S"
  branch_name = "owlbot/all-#{timestamp}"
  message = build_commit_message "all gems"
  result = yoshi_pr_generator.capture enabled: !git_remote.nil?,
                                      remote: git_remote,
                                      branch_name: branch_name,
                                      commit_message: message do
    gems.each_with_index do |name, index|
      process_single_gem name, temp_staging_dir
      puts "Completed #{name} (#{index}/#{gems.size})..."
    end
  end
  output_result "all gems", result, :bold
end

def build_commit_message name
  if commit_message
    match = /^(\w+)(?:\([^)]+\))?(!?):(.*)/.match commit_message
    return "#{match[1]}(#{name})#{match[2]}:#{match[3]}" if match
  end
  "[CHANGE ME] OwlBot on-demand for #{name}"
end

def process_single_gem name, temp_staging_dir
  mkdir_p STAGING_DIR_NAME
  mv File.join(temp_staging_dir, name), File.join(STAGING_DIR_NAME, name)
  docker_run "#{POSTPROCESSOR_IMAGE}:#{postprocessor_tag}", "--gem", name
  return unless enable_tests
  cd name do
    exec ["bundle", "install"]
    # The MT_COMPAT environment variable is a temporary hack to allow
    # minitest-rg 5.2.0 to work in minitest 5.19 or later. This should be
    # removed if we have a better solution or decide to drop rg.
    exec ["bundle", "exec", "rake", "ci"], env: { "MT_COMPAT" => "true" }
  end
end

def final_output results
  puts
  puts "Final results:", :bold
  if results.is_a? Hash
    results.each do |name, result|
      output_result name, result
    end
  else
    output_result "all gems", results
  end
end

def output_result name, result, *style
  case result
  when Integer
    puts "#{name}: Created pull request #{result}", *style
  when :unchanged
    puts "#{name}: No pull request created because nothing changed", *style
  else
    puts "#{name}: Results left in the local directory", *style
  end
  result
end

def docker_run *args
  cmd = [
    "docker", "run",
    "--rm",
    "--user", "#{Process.uid}:#{Process.gid}",
    "-v", "#{context_directory}:/repo",
    "-w", "/repo",
    "--env", "HOME=/repo"
  ] + args
  exec cmd
end

def bazel_base_dir
  @bazel_base_dir ||=
    if piper_client
      piper_client_dir = capture(["p4", "g4d", piper_client]).strip
      File.join piper_client_dir, "third_party", "googleapis", "stable"
    elsif protos_path
      File.expand_path protos_path
    else
      error "No protos directory"
    end
end

def error str
  logger.error str
  exit 1
end
