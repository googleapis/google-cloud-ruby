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

def delete_job_template project_id:, location:, template_id:
  # [START transcoder_delete_job_template]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location    = "YOUR-JOB-TEMPLATE-LOCATION"  # (e.g. "us-central1")
  # template_id = "YOUR-JOB-TEMPLATE"  # (e.g. "my-job-template")

  # Require the Transcoder client library.
  require "google/cloud/video/transcoder"

  # Create a Transcoder client.
  client = Google::Cloud::Video::Transcoder.transcoder_service

  # Build the resource name of the job template.
  name = client.job_template_path project: project_id, location: location, job_template: template_id

  # Delete the job template.
  client.delete_job_template name: name

  # Print a success message.
  puts "Deleted job template"
  # [END transcoder_delete_job_template]
end


if $PROGRAM_NAME == __FILE__
  args    = ARGV.dup
  command = args.shift

  case command
  when "delete_job_template"
    delete_job_template(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location:  args.shift,
      template_id:  args.shift
    )
  else
    puts <<~USAGE
      Usage: bundle exec ruby #{__FILE__} [command] [arguments]

      Commands:
        delete_job_template <location> <template_id>  Delete a job template

      Environment variables:
        GOOGLE_CLOUD_PROJECT    ID of the Google Cloud project to run snippets
    USAGE
  end
end
