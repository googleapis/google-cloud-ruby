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


batch_reviewer = Yoshi::BatchReviewer.new "googleapis/google-cloud-ruby"

batch_reviewer.define_preset "releases-gapics" do |preset|
  preset.desc = "Selects release pull requests for GAPICs, and expect diffs appropriate to a release pull request"
  preset.pull_request_filter.only_titles(/^chore\(main\): release [\w-]+-v\d\w* \d+\.\d+\.\d+/)
  preset.pull_request_filter.only_users(["release-please[bot]"])
  preset.diff_expectations.expect_changed_paths(/\.release-please-manifest\.json$/)
  preset.diff_expectations.expect_changed_paths(/\/CHANGELOG\.md$/)
  preset.diff_expectations.expect_changed_paths(/\/version\.rb$/)
  preset.diff_expectations.expect_changed_paths(/\/snippets\/snippet_metadata_[\w\.]+\.json$/)
end

batch_reviewer.define_preset "releases-wrappers" do |preset|
  preset.desc = "Selects release pull requests for wrappers and handwritten libraries, and expect diffs appropriate " \
                "to a release pull request"
  preset.pull_request_filter.only_titles(/^chore\(main\): release (\w+-)*(v[a-z_]|[a-uw-z])\w* \d+\.\d+\.\d+/)
  preset.pull_request_filter.only_users(["release-please[bot]"])
  preset.diff_expectations.expect_changed_paths(/\.release-please-manifest\.json$/)
  preset.diff_expectations.expect_changed_paths(/\/CHANGELOG\.md$/)
  preset.diff_expectations.expect_changed_paths(/\/version\.rb$/)
  preset.diff_expectations.expect_changed_paths(/\/snippets\/snippet_metadata_[\w\.]+\.json$/)
end

batch_reviewer.define_preset "releases" do |preset|
  preset.desc = "Selects all release pull requests, and expect diffs appropriate to a release pull request"
  preset.pull_request_filter.only_titles(/^chore\(main\): release [\w-]+ \d+\.\d+\.\d+/)
  preset.pull_request_filter.only_users(["release-please[bot]"])
  preset.diff_expectations.expect_changed_paths(/\.release-please-manifest\.json$/)
  preset.diff_expectations.expect_changed_paths(/\/CHANGELOG\.md$/)
  preset.diff_expectations.expect_changed_paths(/\/version\.rb$/)
  preset.diff_expectations.expect_changed_paths(/\/snippets\/snippet_metadata_[\w\.]+\.json$/)
end

batch_reviewer.define_preset "owlbot" do |preset|
  preset.desc = "Selects all OwlBot pull requests"
  preset.pull_request_filter.only_users(["gcf-owl-bot[bot]"])
end

expand Yoshi::BatchReviewer::Template, batch_reviewer
