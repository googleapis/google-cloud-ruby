# Copyright 2023 Google, Inc
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

require "google/cloud/pubsub"

def list_schemas
  # [START pubsub_old_version_list_schemas]

  pubsub = Google::Cloud::Pubsub.new

  schemas = pubsub.schemas

  puts "Schemas in project:"
  schemas.each do |schema|
    puts schema.name
  end
  # [END pubsub_old_version_list_schemas]
end
