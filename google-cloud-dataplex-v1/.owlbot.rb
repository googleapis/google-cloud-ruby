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

# Fix a camel cased pattern variable name.
# See https://github.com/googleapis/gapic-generator-ruby/issues/894
paths = [
  "lib/google/cloud/dataplex/v1/data_scan_service/paths.rb",
  "lib/google/cloud/dataplex/v1/data_taxonomy_service/paths.rb",
  "test/google/cloud/dataplex/v1/data_scan_service_paths_test.rb",
  "test/google/cloud/dataplex/v1/data_taxonomy_service_paths_test.rb"
]
OwlBot.modifier path: paths do |content|
  content
    .gsub(/dataScan(?=[^s])/, "data_scan")
    .gsub(/dataTaxonomy(?=[^s])/, "data_taxonomy")
end

OwlBot.move_files
