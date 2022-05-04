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

FileUtils.rm_rf File.join(OwlBot.staging_dir, "lib/google/cloud/location")
FileUtils.rm_f File.join(OwlBot.staging_dir, "lib/google/cloud/location.rb")
FileUtils.rm_rf File.join(OwlBot.staging_dir, "proto_docs/google/cloud/location")
FileUtils.rm_rf File.join(OwlBot.staging_dir, "snippets/locations")
FileUtils.rm_f File.join(OwlBot.staging_dir, "snippets/snippet_metadata_google.cloud.location.json")
FileUtils.rm_rf File.join(OwlBot.staging_dir, "test/google/cloud/location")

OwlBot.move_files
