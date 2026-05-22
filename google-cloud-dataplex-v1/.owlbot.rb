# Copyright 2026 Google LLC
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

# (b/501191424): Manual removal of empty ContentService files since it contains no RPC definitions,
# preventing gRPC from generating a Stub class for it. To be removed once bug is fixed upstream.
FileUtils.rm_rf File.join(OwlBot.staging_dir, "lib", "google", "cloud", "dataplex", "v1", "content_service")
FileUtils.rm_f File.join(OwlBot.staging_dir, "lib", "google", "cloud", "dataplex", "v1", "content_service.rb")
FileUtils.rm_f File.join(OwlBot.staging_dir, "test", "google", "cloud", "dataplex", "v1", "content_service_test.rb")
FileUtils.rm_f File.join(OwlBot.staging_dir, "test", "google", "cloud", "dataplex", "v1", "content_service_paths_test.rb")
FileUtils.rm_f File.join(OwlBot.staging_dir, "test", "google", "cloud", "dataplex", "v1", "content_service_rest_test.rb")

OwlBot.modifier path: "lib/google/cloud/dataplex/v1.rb" do |content|
  content.sub!(/require "google\/cloud\/dataplex\/v1\/content_service"\n/, "")
  content
end

OwlBot.move_files
