# Copyright 2023 Google LLC
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

# OwlBot script for google-cloud-support-v2

lib_paths = [
  "lib/google/cloud/support/v2/case_attachment_service/paths.rb",
  "lib/google/cloud/support/v2/case_service/paths.rb",
  "lib/google/cloud/support/v2/comment_service/paths.rb"
]

# Fix for b/283189019 (internal)
OwlBot.modifier path: lib_paths do |content|
  # The regex matches following conditions:
  # - Ignore comments
  # - Look for occurences of 'case' in method definitions, but
  #   ignore the keyword arguments (ex: case:)
  content&.gsub(/^((?!\s*#).*\b)(case)\b[^:]/) do |match|
    match
      .split(/\bcase\b/) # ensure we don't change false positives of 'case' (ex: cases)
      .join("binding.local_variable_get(:case)") # This works according to https://stackoverflow.com/a/45654031
  end
end

test_paths = [
  "test/google/cloud/support/v2/case_service_test.rb"
]

# Fix for b/283189019 (internal)
OwlBot.modifier path: test_paths do |content|
  content&.gsub(/\scase([^:])/) do |_match|
    "a_case#{Regexp.last_match 1}"
  end
end

OwlBot.move_files
