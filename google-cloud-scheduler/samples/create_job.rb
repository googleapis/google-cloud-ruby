# frozen_string_literal: true

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def create_job project_id:, location_id:, service_id:
  # [START cloud_scheduler_create_job]
  require "google/cloud/scheduler"

  # Create a client.
  client = Google::Cloud::Scheduler.cloud_scheduler

  # TODO(developer): Uncomment and set the following variables
  # project_id = "PROJECT_ID"
  # location_id = "LOCATION_ID"
  # service_id = "my-serivce"

  # Construct the fully qualified location path.
  parent = client.location_path project: project_id, location: location_id

  # Construct the request body.
  job = {
    app_engine_http_target: {
      app_engine_routing: {
        service: service_id
      },
      relative_uri:       "/log_payload",
      http_method:        "POST",
      body:               "Hello World"
    },
    schedule:               "* * * * *",
    time_zone:              "America/Los_Angeles"
  }

  # Use the client to send the job creation request.
  response = client.create_job parent: parent, job: job

  puts "Created job: #{response.name}"
  # [END cloud_scheduler_create_job]
  response.name
end
