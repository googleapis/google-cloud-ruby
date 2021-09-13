# Copyright 2021 Google, Inc
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

def list_job_templates project_id:, location:
  # [START transcoder_list_job_templates]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location    = "YOUR-JOB-TEMPLATE-LOCATION"  # (e.g. "us-central1")

  # Require the Transcoder client library.
  require "google/cloud/video/transcoder"

  # Create a Transcoder client.
  client = Google::Cloud::Video::Transcoder.transcoder_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location

  # Get the list of job templates.
  response = client.list_job_templates parent: parent

  puts "Job templates:"
  # Print out all job templates.
  response.each do |job_template|
    puts job_template.name.to_s
  end
  # [END transcoder_list_job_templates]
end


if $PROGRAM_NAME == __FILE__
  args    = ARGV.dup
  command = args.shift

  case command
  when "list_job_templates"
    list_job_templates(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location:  args.shift
    )
  else
    puts <<~USAGE
      Usage: bundle exec ruby #{__FILE__} [command] [arguments]

      Commands:
        list_job_templates <location> List all job templates for a given location

      Environment variables:
        GOOGLE_CLOUD_PROJECT    ID of the Google Cloud project to run snippets
    USAGE
  end
end
