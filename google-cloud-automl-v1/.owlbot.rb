# Copyright 2021 Google LLC
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

# Fixes for some misformatted markdown links.
# See internal issue b/153077040.
OwlBot.modifier path: "proto_docs/google/cloud/automl/v1/io.rb" do |content|
  content.gsub %r{https:\n\s+# //},
               "https://"
end

# See internal issue b/158466893
OwlBot.modifier path: "proto_docs/google/cloud/automl/v1/io.rb" do |content|
  content.gsub %r{\[display_name-s\]\[google\.cloud\.automl\.v1\.ColumnSpec\.display_name\]},
               "display_name-s"
end

OwlBot.move_files
