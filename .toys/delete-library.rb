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

desc "A tool that removes a client library from the repository"

required_arg :gem_name

flag :git_remote, "--remote=NAME" do
  desc "The name of the git remote to use as the pull request head. If omitted, does not open a pull request."
end
flag :enable_fork, "--fork" do
  desc "Use a fork to open the pull request"
end

include :fileutils
include :exec, e: true
include "yoshi-pr-generator"

def run
  setup
  branch_name = "pr/delete/#{gem_name}"
  message = "chore: remove #{gem_name}"
  result = yoshi_pr_generator.capture enabled: !git_remote.nil?,
                                      remote: git_remote,
                                      branch_name: branch_name,
                                      commit_message: message do
    remove_release_manifest
    remove_release_config
    remove_directory
  end
  puts "Pull request result: #{result}"
end

def setup
  cd context_directory
  yoshi_utils.git_ensure_identity
  return unless enable_fork
  set :git_remote, "pull-request-fork" unless git_remote
  yoshi_utils.gh_ensure_fork remote: git_remote
end

def remove_release_manifest
  content = File.read ".release-please-manifest.json"
  content.sub!(/\n  "#{gem_name}": "\d+\.\d+\.\d+",\n/, "\n")
  content.sub! ",\n  \"#{gem_name}+FILLER\": \"0.0.0\"", ""
  File.write ".release-please-manifest.json", content
end

def remove_release_config
  config_json = JSON.parse File.read "release-please-config.json"
  config_json["packages"].delete gem_name
  File.write "release-please-config.json", "#{JSON.pretty_generate config_json}\n"
end

def remove_directory
  rm_rf gem_name
end
