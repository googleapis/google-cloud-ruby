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

# This client is generated originally as "google-apps-chat-v1", but we're modifying
# the card.rb under proto_docs folder as yard check fails due to an enum called END
# which is a Ruby keyword. This code comments out this line to make yard check pass.
# The files under proto_docs folder are not used by the library to this change is safe.

file_paths = [
  "proto_docs/google/apps/card/v1/card.rb"
]
OwlBot.modifier path: file_paths, name: "Comment END enum line" do |content|
  ruby_keyword_match = content.match(/END = \d+/)
  content.gsub(/END = \d+/, "# #{ruby_keyword_match}")
end

OwlBot.move_files
