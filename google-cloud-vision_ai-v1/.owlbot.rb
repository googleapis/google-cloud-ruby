# Copyright 2024 Google LLC
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

# Fix some cases of incorrect quoting around path patterns (closing quote is
# a single quote rather than backtick)
paths = [
  "proto_docs/google/cloud/visionai/v1/warehouse.rb",
  "lib/google/cloud/vision_ai/v1/warehouse/client.rb",
  "lib/google/cloud/vision_ai/v1/warehouse/rest/client.rb"
]
OwlBot.modifier path: paths do |content|
  content.gsub %r!`(\w+(/(\w+|\{\w+\}))+)'!, "`\\1`"
end

OwlBot.move_files
