# Copyright 2022 Google LLC
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

# Custom readme because this isn't an end-user client.
OwlBot.prevent_overwrite_of_existing "README.md"

# Remove unused AUTHENTICATION.md
FileUtils.rm_f File.join(OwlBot.staging_dir, "AUTHENTICATION.md")
OwlBot.modifier path: "google-iam-v1.gemspec", name: "Remove auth docs from gemspec" do |content|
  content&.sub '"AUTHENTICATION.md", ', ""
end
OwlBot.modifier path: ".yardopts", name: "Remove auth docs from yardopts" do |content|
  content&.sub "AUTHENTICATION.md\n", ""
end

OwlBot.move_files
