# frozen_string_literal: true

# Copyright 2023 Google LLC
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

desc "A tool that creates a release that just bumps a library version"

remaining_args :gem_names do
  desc "Names of the gems to release"
end

flag :git_remote, "--remote=NAME" do
  desc "The name of the git remote to use as the pull request head. If omitted, does not open a pull request."
end
flag :enable_fork, "--fork" do
  desc "Use a fork to open the pull request"
end
flag :automerge do
  desc "Automatically merge the pull request"
end
flag :approval_token, "--approval-token" do
  default ENV["APPROVAL_GITHUB_TOKEN"]
  desc "GitHub token for adding labels to pull requests"
end
flag :changelog_entry, "--changelog-entry=MESSAGE" do
  desc "Custom changelog entry"
  long_desc \
    "Specifies a changelog entry for new releases opened. Be sure to quote " \
    "the argument if the desired entry includes whitespace."
end
all_required do
  flag :gem_version, "--version=VERSION" do
    desc "Use the specified gem version"
  end
end

include :fileutils
include :terminal
include :exec, e: true
include "yoshi-pr-generator"

def run
  setup
  verify_version
  pr_number = open_change_pr
  process_change_pr pr_number if git_remote && automerge
end

def setup
  require "json"
  cd context_directory
  yoshi_utils.git_ensure_identity
  if enable_fork
    set :git_remote, "pull-request-fork" unless git_remote
    yoshi_utils.gh_ensure_fork remote: git_remote
  end
  set :changelog_entry, "Bump version to #{gem_version}" unless changelog_entry
end

def verify_version
  unless gem_version =~ /^\d+\.\d+\.\d+$/
    raise "Bad version format: #{gem_version}"
  end
  manifest_data = JSON.parse File.read ".release-please-manifest.json"
  gem_names.each do |gem_name|
    cur_version = manifest_data[gem_name]
    raise "Gem not found in manifest: #{gem_name}" unless cur_version
    if Gem::Version.new(cur_version) >= Gem::Version.new(gem_version)
      raise "Backwards version bump: #{gem_name}: #{cur_version} -> #{gem_version}"
    end
  end
end

def open_change_pr
  timestamp = Time.now.utc.strftime "%Y%m%d-%H%M%S"
  salt = format "%06d", rand(1_000_000)
  branch_name = "bump/#{timestamp}-#{salt}"
  message = "feat: #{changelog_entry}"
  pr_body = "Release-As: #{gem_version}"
  result = yoshi_pr_generator.capture enabled: !git_remote.nil?,
                                      remote: git_remote,
                                      branch_name: branch_name,
                                      pr_body: pr_body,
                                      commit_message: message do
    gem_names.each do |gem_name|
      changelog_path = File.join gem_name, "CHANGELOG.md"
      content = File.read changelog_path
      File.write changelog_path, "#{content}\n"
    end
  end
  puts "Pull request: #{result}", :bold
  result
end

def process_change_pr pr_number
  yoshi_utils.gh_with_token(approval_token || yoshi_utils.gh_cur_token) do
    approve_pr pr_number
    wait_for_pr_checks pr_number
    merge_pr pr_number
    label_pr pr_number
  end
end

def approve_pr pr_number
  cmd = [
    "gh", "pr", "review", pr_number,
    "--approve",
    "--body", "Auto-approved by bump-version"
  ]
  exec cmd
  puts "Pull request #{pr_number} approved"
end

def wait_for_pr_checks pr_number
  puts "Waiting for #{pr_number} checks..."
  exec ["gh", "pr", "checks", pr_number, "--watch", "--interval=60", "--required"]
  puts "Checks finished for #{pr_number}"
end

def merge_pr pr_number
  cmd = [
    "gh", "pr", "merge", pr_number,
    "--squash",
    "--delete-branch",
    "--subject", "feat: #{changelog_entry}",
    "--body", "Release-As: #{gem_version}\n"
  ]
  exec cmd
  puts "Pull request #{pr_number} merged"
end

def label_pr pr_number
  cmd = [
    "gh", "issue", "edit", pr_number,
    "--add-label", "release-please:force-run"
  ]
  exec cmd
  puts "Triggered release-please on #{pr_number}"
end
