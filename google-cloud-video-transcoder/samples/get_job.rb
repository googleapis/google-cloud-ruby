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

def get_job project_id:, location:, job_id:
  # [START transcoder_get_job]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location   = "YOUR-JOB-LOCATION"  # (e.g. "us-central1")
  # job_id     = "YOUR-JOB-ID"  # (e.g. "c82c295b-3f5a-47df-8562-938a89d40fd0")

  # Require the Transcoder client library.
  require "google/cloud/video/transcoder"

  # Create a Transcoder client.
  client = Google::Cloud::Video::Transcoder.transcoder_service

  # Build the resource name of the job.
  name = client.job_path project: project_id, location: location, job: job_id

  # Get the job.
  job = client.get_job name: name

  # Print the job name.
  puts "Job: #{job.name}"
  # [END transcoder_get_job]

  job
end


if $PROGRAM_NAME == __FILE__
  args    = ARGV.dup
  command = args.shift

  case command
  when "get_job"
    get_job(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location:  args.shift,
      job_id:  args.shift
    )
  else
    puts <<~USAGE
      Usage: bundle exec ruby #{__FILE__} [command] [arguments]

      Commands:
        get_job <location> <job_id> Get a job

      Environment variables:
        GOOGLE_CLOUD_PROJECT    ID of the Google Cloud project to run snippets
    USAGE
  end
end
