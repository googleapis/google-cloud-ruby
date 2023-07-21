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

remaining_args :inputs do
  desc "Gems to release"
  long_desc \
    "The remaining arguments specify which gems to release.",
    "",
    "Each argument should have the form `gem-name[:VERSION[:CHANGELOG]]` " \
    "where VERSION is one of the words `major`, `minor`, or `patch`, or a " \
    "specific version x.y.z, and CHANGELOG is a custom changelog entry to " \
    "use for the release. (Be sure to quote the argument if the changelog " \
    "entry includes spaces.) If version and/or changelog are not specified, " \
    "they default to the settings implied by other flags."
end

flag :git_remote, "--remote=NAME" do
  desc "The name of the git remote to use as the pull request head. If omitted, does not open a pull request."
end
flag :enable_fork, "--fork" do
  desc "Use a fork to open the pull request"
end
flag :default_changelog_entry, "--changelog-entry=MESSAGE" do
  desc "Custom default changelog entry"
  long_desc \
    "Specifies a default changelog entry for new releases opened.",
    "",
    "Be sure to quote the argument if the desired entry includes whitespace. " \
    "You can include the special strings $NAME and/or $VERSION which will be " \
    "replaced by gem name and version, respectively.",
    "",
    "Default is `Bump version to $VERSION`."
  default "Bump version to $VERSION"
end
flag :approval_token, "--approval-token" do
  default ENV["APPROVAL_GITHUB_TOKEN"]
  desc "GitHub token for adding labels to pull requests"
end
at_most_one desc: "Type of version bump (defaults to major)" do
  flag :major, desc: "Bump major version by default"
  flag :minor, desc: "Bump minor version by default"
  flag :patch, desc: "Bump patch version by default"
end

include :fileutils
include :terminal
include :exec, e: true
include "yoshi-pr-generator"

def run
  setup
  labels = ["autorelease: pending"]
  pr_body = "Release proposed by bump-version tool"
  gem_data.each do |(gem_name, gem_version, changelog_entry)|
    message = "chore(main): release #{gem_name} #{gem_version}"
    branch_name = "bump/#{gem_name}"
    result = yoshi_pr_generator.capture enabled: !git_remote.nil?,
                                        remote: git_remote,
                                        branch_name: branch_name,
                                        labels: labels,
                                        approval_token: approval_token,
                                        pr_body: pr_body,
                                        commit_message: message do
      bump_release_manifest gem_name, gem_version
      bump_gem_version gem_name, gem_version
      bump_changelog gem_name, gem_version, changelog_entry
    end
    puts "Pull request for #{gem_name} #{gem_version}: #{result}", :bold
  end
end

def setup
  cd context_directory
  yoshi_utils.git_ensure_identity
  return unless enable_fork
  set :git_remote, "pull-request-fork" unless git_remote
  yoshi_utils.gh_ensure_fork remote: git_remote
end

def gem_data
  @gem_data ||= inputs.map do |input|
    name, version_bump, changelog_entry = input.split ":", 3
    next unless name
    version_bump = interpret_version_bump version_bump
    version = determine_next_version name, version_bump
    changelog_entry ||= interpret_default_changelog_entry name, version
    [name, version, changelog_entry]
  end.compact
end

def interpret_version_bump version_bump
  case version_bump
  when "major"
    :major
  when "minor"
    :minor
  when "patch"
    :patch
  when /^\d+\.\d+\.\d+$/
    version_bump
  when nil
    if minor
      :minor
    elsif patch
      :patch
    else
      :major
    end
  else
    raise "Unrecognized version: #{version_bump}"
  end
end

def determine_next_version gem_name, version_bump
  cur_version = cur_manifest_data[gem_name]
  raise "Gem not found in manifest: #{gem_name}" unless cur_version
  return version_bump unless version_bump.is_a? Symbol
  cur_major, cur_minor, cur_patch = cur_version.split(".").map(&:to_i)
  case version_bump
  when :patch
    cur_patch += 1
  when :minor
    cur_patch = 0
    cur_minor += 1
  when :major
    cur_patch = cur_minor = 0
    cur_major += 1
  end
  "#{cur_major}.#{cur_minor}.#{cur_patch}"
end

def interpret_default_changelog_entry name, version
  return "Bump version to #{version}" unless default_changelog_entry
  default_changelog_entry.gsub("$NAME", name).gsub("$VERSION", version)
end

def cur_manifest_data
  require "json"
  @cur_manifest_data ||= JSON.parse File.read ".release-please-manifest.json"
end

def bump_release_manifest gem_name, gem_version
  content = File.read ".release-please-manifest.json"
  content.sub!(/\n  "#{gem_name}": "\d+\.\d+\.\d+",\n/, "\n  \"#{gem_name}\": \"#{gem_version}\",\n")
  File.write ".release-please-manifest.json", content
end

def bump_gem_version gem_name, gem_version
  version_path = File.join gem_name, "lib", *gem_name.split("-"), "version.rb"
  content = File.read version_path
  content.sub!(/VERSION = "\d+\.\d+\.\d+"/, "VERSION = \"#{gem_version}\"")
  File.write version_path, content
end

def bump_changelog gem_name, gem_version, changelog_entry
  changelog_path = File.join gem_name, "CHANGELOG.md"
  content = File.read changelog_path
  cur_date = Time.now.strftime "%Y-%m-%d"
  content.sub!(/\A\s*(#[^\n]+)\n/, "\\1\n\n### #{gem_version} (#{cur_date})\n\n* #{changelog_entry}\n")
  File.write changelog_path, content
end
