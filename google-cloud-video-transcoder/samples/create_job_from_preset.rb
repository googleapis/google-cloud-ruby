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

def create_job_from_preset project_id:, location:, input_uri:, output_uri:, preset:
  # [START transcoder_create_job_from_preset]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location    = "YOUR-JOB-LOCATION"  # (e.g. "us-central1")
  # input_uri   = "YOUR-GCS-INPUT-VIDEO"  # (e.g. "gs://my-bucket/my-video-file")
  # output_uri  = "YOUR-GCS-OUTPUT-FOLDER/"  # (e.g. "gs://my-bucket/my-output-folder/")
  # preset      = "YOUR-JOB-PRESET"  # (e.g. "preset/web-hd")

  # Require the Transcoder client library.
  require "google/cloud/video/transcoder"

  # Create a Transcoder client.
  client = Google::Cloud::Video::Transcoder.transcoder_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location

  # Set the job fields.
  new_job = {
    input_uri: input_uri,
    output_uri: output_uri,
    template_id: preset
  }

  job = client.create_job parent: parent, job: new_job

  # Print the job name.
  puts "Job: #{job.name}"
  # [END transcoder_create_job_from_preset]

  job
end


if $PROGRAM_NAME == __FILE__
  args    = ARGV.dup
  command = args.shift

  case command
  when "create_job_from_preset"
    create_job_from_preset(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location:  args.shift,
      input_uri:  args.shift,
      output_uri:  args.shift,
      preset: args.shift
    )
  else
    puts <<~USAGE
      Usage: bundle exec ruby #{__FILE__} [command] [arguments]

      Commands:
        create_job_from_preset <location> <input_uri> <output_uri> <preset> Create a job using a preset

      Environment variables:
        GOOGLE_CLOUD_PROJECT    ID of the Google Cloud project to run snippets
    USAGE
  end
end
