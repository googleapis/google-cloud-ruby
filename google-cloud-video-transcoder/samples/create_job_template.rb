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

def create_job_template project_id:, location:, template_id:
  # [START transcoder_create_job_template]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location    = "YOUR-JOB-TEMPLATE-LOCATION"  # (e.g. "us-central1")
  # template_id = "YOUR-JOB-TEMPLATE"  # (e.g. "my-job-template")

  # Require the Transcoder client library.
  require "google/cloud/video/transcoder"

  # Create a Transcoder client.
  client = Google::Cloud::Video::Transcoder.transcoder_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location

  # Build the job template.
  new_job_template = {
    config: {
      elementary_streams: [
        {
          key: "video-stream0",
          video_stream: {
            h264: {
              height_pixels: 360,
              width_pixels: 640,
              bitrate_bps: 550_000,
              frame_rate: 60
            }
          }
        },
        {
          key: "video-stream1",
          video_stream: {
            h264: {
              height_pixels: 720,
              width_pixels: 1280,
              bitrate_bps: 2_500_000,
              frame_rate: 60
            }
          }
        },
        {
          key: "audio-stream0",
          audio_stream: {
            codec: "aac",
            bitrate_bps: 64_000
          }
        }
      ],
      mux_streams: [
        {
          key: "sd",
          container: "mp4",
          elementary_streams: [
            "video-stream0",
            "audio-stream0"
          ]
        },
        {
          key: "hd",
          container: "mp4",
          elementary_streams: [
            "video-stream1",
            "audio-stream0"
          ]
        }
      ]
    }
  }

  job_template = client.create_job_template parent: parent, job_template: new_job_template, job_template_id: template_id

  # Print the job template name.
  puts "Job template: #{job_template.name}"
  # [END transcoder_create_job_template]

  job_template
end


if $PROGRAM_NAME == __FILE__
  args    = ARGV.dup
  command = args.shift

  case command
  when "create_job_template"
    create_job_template(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location:  args.shift,
      template_id:  args.shift
    )
  else
    puts <<~USAGE
      Usage: bundle exec ruby #{__FILE__} [command] [arguments]

      Commands:
        create_job_template <location> <template_id>  Create a job template

      Environment variables:
        GOOGLE_CLOUD_PROJECT    ID of the Google Cloud project to run snippets
    USAGE
  end
end
