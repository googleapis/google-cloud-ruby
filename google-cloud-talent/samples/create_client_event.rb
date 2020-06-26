# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def sample_create_client_event project_id,
                               tenant_id,
                               request_id,
                               event_id,
                               job_one,
                               job_two
  # [START job_search_create_client_event]
  require "google/cloud/talent"

  # Instantiate a client
  event_client = Google::Cloud::Talent.event_service

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is optional)"
  parent = event_client.tenant_path project: project_id, tenant: tenant_id

  # The timestamp of the event as seconds of UTC time since Unix epoch
  # For more information on how to create google.protobuf.Timestamps
  # See: https://github.com/protocolbuffers/protobuf/blob/master/src/google/protobuf/timestamp.proto
  seconds = 1
  create_time = { seconds: seconds }

  # The type of event attributed to the behavior of the end user
  type = :VIEW

  # List of job names associated with this event
  # job_one = "projects/[Project ID]/tenants/[Tenant ID]/jobs/[Job ID]"
  # job_two = "projects/[Project ID]/tenants/[Tenant ID]/jobs/[Job ID]"
  jobs = [job_one, job_two]
  job_event = { type: type, jobs: jobs }

  # request_id = "[request_id from ResponseMetadata]"
  # event_id = "[Set this to a unique identifier]"
  client_event = {
    request_id:  request_id,
    event_id:    event_id,
    create_time: create_time,
    job_event:   job_event
  }

  response = event_client.create_client_event parent: parent, client_event: client_event
  puts "Created client event: #{response.event_id}"
  # [END job_search_create_client_event]
end

require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is optional)"
  request_id = "[request_id from ResponseMetadata]"
  event_id = "[Set this to a unique identifier]"
  job_one = "The name of a job"
  job_two = "The name of a second job"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--request_id=val") { |val| request_id = val }
    opts.on("--event_id=val") { |val| event_id = val }
    opts.on("--job_one=val") { |val| job_one = val }
    opts.on("--job_two=val") { |val| job_two = val }
    opts.parse!
  end


  sample_create_client_event project_id, tenant_id, request_id, event_id, job_one, job_two
end
