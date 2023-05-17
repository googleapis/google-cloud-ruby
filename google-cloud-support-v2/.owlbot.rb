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

paths = [
  "lib/google/cloud/support/v2/case_attachment_service/paths.rb",
  "lib/google/cloud/support/v2/case_service/paths.rb",
  "lib/google/cloud/support/v2/comment_service/paths.rb"
]

OwlBot.modifier path: paths, name: "Replace reserved keyword case with a non-reserved keyword" do |content|
  content&.gsub(/\bcase\b/, "pathcase")
end

OwlBot.move_files
