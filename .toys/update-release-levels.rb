# frozen_string_literal: true

# Copyright 2022 Google LLC
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

desc "Updates all release levels in repo-metadata.json files"

flag :git_remote, "--remote=NAME" do
  desc "The name of the git remote to use as the pull request head. If omitted, does not open a pull request."
end

include :exec, e: true

def run
  require "json"
  require "pull_request_generator"
  extend PullRequestGenerator

  updated, pr_result = update_release_levels
  output_result updated, pr_result
end

def update_release_levels
  timestamp = Time.now.utc.strftime("%Y%m%d-%H%M%S")
  branch_name = "pr/update-release-levels-#{timestamp}"
  updated = []
  pr_result = generate_pull_request git_remote: git_remote,
                                    branch_name: branch_name,
                                    commit_message: "chore: Update release levels in repo-metadata" do
    selected_gems.each do |gem_name|
      updated << gem_name if update_gem gem_name
    end
  end
  [updated, pr_result]
end

def output_result updated, pr_result, *style
  puts "Updated: #{updated.inspect}", *style
  case pr_result
  when :opened
    puts "Created pull request", *style
  when :unchanged
    puts "No pull request created because nothing changed", *style
  when :disabled
    puts "Results left in the local directory", *style
  else
    puts "Unknown result #{result.inspect}", *style
  end
end

def selected_gems
  Dir.chdir context_directory
  Dir.glob("*/.repo-metadata.json")
    .map { |path| File.dirname path }
    .find_all { |gem_name| File.file? "#{gem_name}/#{gem_name}.gemspec" }
    .sort
end

def update_gem gem_name
  release_level = current_gem_version(gem_name).start_with?("0.") ? "preview" : "stable"
  metadata = File.read "#{gem_name}/.repo-metadata.json"
  updated_metadata = metadata.sub(/"release_level": "\w+"/, "\"release_level\": \"#{release_level}\"")
  if metadata == updated_metadata
    logger.info "No change for #{gem_name}"
    return false
  end
  logger.info "Updated repo-metadata for #{gem_name}"
  File.open "#{gem_name}/.repo-metadata.json", "w" do |file|
    file.write updated_metadata
  end
  true
end

def current_gem_version gem_name
  func = proc do
    Dir.chdir gem_name do
      spec = Gem::Specification.load "#{gem_name}.gemspec"
      puts spec.version
    end
  end
  capture_proc(func).strip
end
