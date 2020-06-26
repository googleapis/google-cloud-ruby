# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License")
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START cloud_tasks_create_http_task]
require "google/cloud/tasks"

# Create a Task with an HTTP Target
#
# @param [String] project_id Your Google Cloud Project ID.
# @param [String] location_id Your Google Cloud Project Location ID.
# @param [String] queue_id Your Google Cloud Tasks Queue ID.
# @param [String] url The full path to sent the task request to.
# @param [String] payload The request body of your task.
# @param [Integer] seconds The delay, in seconds, to process your task.
def create_http_task project_id, location_id, queue_id, url, payload: nil, seconds: nil
  # Instantiates a client.
  client = Google::Cloud::Tasks.cloud_tasks

  # Construct the fully qualified queue name.
  parent = client.queue_path project: project_id, location: location_id, queue: queue_id

  # Construct task.
  task = {
    http_request: {
      http_method: "POST",
      url:         url
    }
  }

  # Add payload to task body.
  task[:http_request][:body] = payload if payload

  # Add scheduled time to task.
  if seconds
    timestamp = Google::Protobuf::Timestamp.new
    timestamp.seconds = Time.now.to_i + seconds.to_i
    task[:schedule_time] = timestamp
  end

  # Send create task request.
  puts "Sending task #{task}"

  response = client.create_task parent: parent, task: task

  puts "Created task #{response.name}" if response.name
end
# [END cloud_tasks_create_http_task]

if $PROGRAM_NAME == __FILE__
  project_id  = ENV["GOOGLE_CLOUD_PROJECT"]
  location_id = ARGV.shift
  queue_id    = ARGV.shift
  url         = ARGV.shift
  payload     = ARGV.shift
  seconds     = ARGV.shift

  if project_id && queue_id && location_id && url
    create_http_task(
      project_id,
      location_id,
      queue_id,
      url,
      payload: payload,
      seconds: seconds
    )
  else
    puts <<~USAGE
      Usage: ruby create_http_task.rb <LOCATION_ID> <QUEUE_ID> <URL> <payload> <seconds>

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
        GOOGLE_APPLICATION_CREDENTIALS set to the path to your JSON credentials

    USAGE
  end
end
