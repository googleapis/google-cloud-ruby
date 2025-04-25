# frozen_string_literal: true

# Copyright 2024 Google LLC
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

# The batch-reviewer implementation is in the ruby-common-tools repo.
# Here we load that implementation and configure it for google-cloud-ruby.

if ENV["RUBY_COMMON_TOOLS"]
  common_tools_dir = File.expand_path ENV["RUBY_COMMON_TOOLS"]
  load File.join(common_tools_dir, "toys", "batch-review")
else
  load_git remote: "https://github.com/googleapis/ruby-common-tools.git",
           path: "toys/batch-review",
           update: true
end

batch_reviewer = Yoshi::BatchReviewer.new "googleapis/google-cloud-ruby"

batch_reviewer.define_preset "releases", based_on: :basic_releases do |preset|
  preset.diff_expectations.expect name: "snippet metadata" do |expect|
    expect.change_type(:changed).path_pattern(/\/snippets\/snippet_metadata_[\w\.]+\.json$/)
  end
  preset.diff_expectations.expect name: "repo metadata" do |expect|
    expect.change_type(:changed).path_pattern(/\/\.repo-metadata\.json$/)
  end
end

batch_reviewer.define_preset "releases-gapics", based_on: "releases" do |preset|
  preset.desc = "Selects release pull requests for GAPICs, and expect diffs appropriate to a release pull request"
  preset.pull_request_filter.clear_only_titles!
  preset.pull_request_filter.only_titles(/^chore\(main\): release [\w-]+-v\d\w* \d+\.\d+\.\d+/)
end

batch_reviewer.define_preset "releases-wrappers", based_on: "releases" do |preset|
  preset.desc = "Selects release pull requests for wrappers and handwritten libraries, and expect diffs appropriate " \
                "to a release pull request"
  preset.pull_request_filter.clear_only_titles!
  preset.pull_request_filter.only_titles(/^chore\(main\): release (\w+-)*(v[a-z_]|[a-uw-z])\w* \d+\.\d+\.\d+/)
end

batch_reviewer.define_preset "owlbot" do |preset|
  preset.desc = "Selects all OwlBot pull requests"
  preset.pull_request_filter.only_users Array "gcf-owl-bot[bot]"
  preset.diff_expectations.expect name: "protobuf descriptor files" do |expect|
    expect.path_pattern(/_pb\.rb$/)
  end
end

expand Yoshi::BatchReviewer::Template, batch_reviewer

long_desc \
  "",
  "Some useful patterns:",
  "",
  ["toys batch-review --config=releases --automerge"],
  ["  ", "Merges all open release pull requests that do not have the \"do not merge\" label"],
  "",
  ["toys batch-review --config=owlbot"],
  ["  ", "Interactively reviews all owlbot pull requests"]
