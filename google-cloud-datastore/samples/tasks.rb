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

def create_client
  # [START datastore_build_service]
  require "google/cloud/datastore"

  datastore = Google::Cloud::Datastore.new
  # [END datastore_build_service]
end

# [START datastore_add_entity]
def add_task description
  require "google/cloud/datastore"

  datastore = Google::Cloud::Datastore.new

  task = datastore.entity "Task" do |t|
    t["description"] = description
    t["created"]     = Time.now
    t["done"]        = false
    t.exclude_from_indexes! "description", true
  end

  datastore.save task

  puts task.key.id

  task.key.id
end
# [END datastore_add_entity]

# [START datastore_update_entity]
def mark_done task_id
  require "google/cloud/datastore"

  datastore = Google::Cloud::Datastore.new

  task = datastore.find "Task", task_id

  task["done"] = true

  datastore.save task
end
# [END datastore_update_entity]

# [START datastore_retrieve_entities]
def list_tasks
  require "google/cloud/datastore"

  datastore = Google::Cloud::Datastore.new

  query = datastore.query("Task").order("created")
  tasks = datastore.run query

  tasks.each do |t|
    puts t["description"]
    puts t["done"] ? "  Done" : "  Not Done"
    puts "  ID: #{t.key.id}"
  end
end
# [END datastore_retrieve_entities]

# [START datastore_delete_entity]
def delete_task task_id
  require "google/cloud/datastore"

  datastore = Google::Cloud::Datastore.new

  task = datastore.find "Task", task_id

  datastore.delete task
end
# [END datastore_delete_entity]

if $PROGRAM_NAME == __FILE__
  create_client ENV["GOOGLE_CLOUD_PROJECT"]
  case ARGV.shift
  when "new"
    add_task ARGV.shift
  when "done"
    mark_done ARGV.shift.to_i
  when "list"
    list_tasks
  when "delete"
    delete_task ARGV.shift.to_i
  else
    puts <<~USAGE
      Usage: bundle exec ruby tasks.rb [command] [arguments]

      Commands:
        new <description>    Adds a task with description <description>.
        done <task_id>       Marks a task as done.
        list                 Lists all tasks by creation time.
        delete <task_id>     Deletes a task.

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end
