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

# This client is generated originally as "google-iam", but we're renaming
# it to "google-iam-client" because Rubygems already contains a gem named
# "google-iam". To accomplish this change, we've renamed the directory to
# "google-iam-client", and we're directing the owlbot postprocessor to update
# the gem name as follows.

Dir.chdir OwlBot.staging_dir do
  FileUtils.mv "google-iam.gemspec", "google-iam-client.gemspec"
  FileUtils.mv "lib/google-iam.rb", "lib/google-iam-client.rb"
  FileUtils.rm_f "lib/google/iam/version.rb"
end

file_paths = [
  ".repo-metadata.json",
  ".rubocop.yml",
  "AUTHENTICATION.md",
  "google-iam-client.gemspec",
  "Rakefile",
  "README.md",
  %r{^lib/.+\.rb$},
  %r{^test/.+\.rb$}
]
OwlBot.modifier path: file_paths, name: "Rename gem" do |content|
  content.gsub(/(?<=[^-\w])google-iam(?=[^-\w])/, "google-iam-client")
         .gsub("google/iam/version", "google/iam/client/version")
         .gsub("Google::Iam::VERSION", "Google::Iam::Client::VERSION")
end

OwlBot.move_files
