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

# Remove a spurious link to a class in a different gem.
# See https://github.com/googleapis/gapic-generator-ruby/issues/824
OwlBot.modifier path: "proto_docs/google/firestore/admin/v1/location.rb" do |content|
  content.gsub "{::Google::Cloud::Location::Location#metadata google.cloud.location.Location.metadata}",
               "`::Google::Cloud::Location::Location#metadata`"
end

OwlBot.move_files
