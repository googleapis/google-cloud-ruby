# Copyright 2025 Google LLC
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

# Remove a spurious link to a class in a different gem.
# See https://github.com/googleapis/gapic-generator-ruby/issues/824
paths = [
  "lib/google/cloud/discovery_engine/v1/user_event_service/client.rb",
  "lib/google/cloud/discovery_engine/v1/user_event_service/rest/client.rb",
  "proto_docs/google/cloud/discoveryengine/v1/user_event_service.rb"
]
OwlBot.modifier path: paths do |content|
  content.gsub "{::Google::Cloud::Location::Location Location}",
               "`::Google::Cloud::Location::Location`"
end

OwlBot.move_files
