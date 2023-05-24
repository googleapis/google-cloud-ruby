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

# Fix for b/283189019 (internal)
# rubocop:disable Lint/InterpolationCheck:
OwlBot.modifier path: "lib/google/cloud/support/v2/case_attachment_service/paths.rb" do |content|
  content&.gsub '#{case}', '#{binding.local_variable_get :case}'
end
# rubocop:enable Lint/InterpolationCheck:

# Fix for b/283189019 (internal)
# rubocop:disable Lint/InterpolationCheck:
OwlBot.modifier path: "lib/google/cloud/support/v2/case_service/paths.rb" do |content|
  content&.gsub '#{case}', '#{binding.local_variable_get :case}'
end
# rubocop:enable Lint/InterpolationCheck:

# Fix for b/283189019 (internal)
# rubocop:disable Lint/InterpolationCheck:
OwlBot.modifier path: "lib/google/cloud/support/v2/comment_service/paths.rb" do |content|
  content&.gsub('#{case}', '#{binding.local_variable_get :case}')
        &.gsub("case.to_s", "binding.local_variable_get(:case).to_s")
end
# rubocop:enable Lint/InterpolationCheck:

# Fix for b/283189019 (internal)
OwlBot.modifier path: "test/google/cloud/support/v2/case_service_test.rb" do |content|
  content&.gsub("case =", "ccase =")
         &.gsub("case: case", "case: ccase")
end

OwlBot.move_files
