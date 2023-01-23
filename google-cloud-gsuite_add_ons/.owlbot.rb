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

# Change the method name to the one specified by the path override.
# See https://github.com/googleapis/gapic-generator-ruby/issues/895
paths = [
  "lib/google/cloud/gsuite_add_ons.rb",
  "test/google/cloud/gsuite_add_ons/client_test.rb",
  "AUTHENTICATION.md"
]
OwlBot.modifier path: paths do |content|
  content.gsub "g_suite_add_ons", "gsuite_add_ons"
end

OwlBot.move_files
