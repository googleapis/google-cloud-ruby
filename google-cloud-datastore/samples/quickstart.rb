# Copyright 2020 Google LLC
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

def quickstart task_name:
  # [START datastore_quickstart]
  # [START require_library]
  # Imports the Google Cloud client library
  require "google/cloud/datastore"
  # [END require_library]

  # Instantiate a client
  datastore = Google::Cloud::Datastore.new

  # The kind for the new entity
  kind = "Task"
  # The name/ID for the new entity
  # task_name = "sampleTask"
  # The Cloud Datastore key for the new entity
  task_key = datastore.key kind, task_name

  # Prepares the new entity
  task = datastore.entity task_key do |t|
    t["description"] = "Buy milk"
  end

  # Saves the entity
  datastore.save task

  puts "Saved #{task.key.name}: #{task['description']}"
  task_key = datastore.find task_key
  # [END datastore_quickstart]
end

if $PROGRAM_NAME == __FILE__
  quickstart
end
