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

def create_job_with_concatenated_inputs project_id:, location:,
                                        input1_uri:, start_time_input1:,
                                        end_time_input1:, input2_uri:,
                                        start_time_input2:, end_time_input2:,
                                        output_uri:
  # [START transcoder_create_job_with_concatenated_inputs]
  # project_id        = # Your project ID, e.g. "my-project"
  # location          = # Data location, e.g. "us-central1"
  # input1_uri        = # First video, e.g. "gs://my-bucket/my-video-file1"
  # start_time_input1 = # Start time in fractional seconds relative to the
  #                     # first input video timeline, e.g. 0.0
  # end_time_input1   = # End time in fractional seconds relative to the
  #                     # first input video timeline, e.g. 8.125
  # input2_uri        = # Second video, e.g. "gs://my-bucket/my-video-file2"
  # start_time_input2 = # Start time in fractional seconds relative to the
  #                     # second input video timeline, e.g. 3.5
  # end_time_input2   = # End time in fractional seconds relative to the
  #                     # second input video timeline, e.g. 15
  # output_uri        = # Output folder, e.g. "gs://my-bucket/my-output-folder/"

  s1_sec = start_time_input1.to_i
  s1_nanos = (start_time_input1.to_f.remainder(1) * 1_000_000_000).round
  e1_sec = end_time_input1.to_i
  e1_nanos = (end_time_input1.to_f.remainder(1) * 1_000_000_000).round

  s2_sec = start_time_input2.to_i
  s2_nanos = (start_time_input2.to_f.remainder(1) * 1_000_000_000).round
  e2_sec = end_time_input2.to_i
  e2_nanos = (end_time_input2.to_f.remainder(1) * 1_000_000_000).round

  # Require the Transcoder client library.
  require "google/cloud/video/transcoder"

  # Create a Transcoder client.
  client = Google::Cloud::Video::Transcoder.transcoder_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location

  # Build the job config.
  new_job = {
    output_uri: output_uri,
    config: {
      inputs: [
        {
          key: "input1",
          uri: input1_uri
        },
        {
          key: "input2",
          uri: input2_uri
        }
      ],
      edit_list: [
        {
          key: "atom1",
          inputs: ["input1"],
          start_time_offset: {
            seconds: s1_sec,
            nanos: s1_nanos
          },
          end_time_offset: {
            seconds: e1_sec,
            nanos: e1_nanos
          }
        },
        {
          key: "atom2",
          inputs: ["input2"],
          start_time_offset: {
            seconds: s2_sec,
            nanos: s2_nanos
          },
          end_time_offset: {
            seconds: e2_sec,
            nanos: e2_nanos
          }
        }
      ],
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
        }
      ]
    }
  }

  job = client.create_job parent: parent, job: new_job

  # Print the job name.
  puts "Job: #{job.name}"
  # [END transcoder_create_job_with_concatenated_inputs]

  job
end


if $PROGRAM_NAME == __FILE__
  args    = ARGV.dup
  command = args.shift

  case command
  when "create_job_with_concatenated_inputs"
    create_job_with_concatenated_inputs(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location:  args.shift,
      input1_uri:  args.shift,
      start_time_input1:  args.shift,
      end_time_input1:  args.shift,
      input2_uri:  args.shift,
      start_time_input2:  args.shift,
      end_time_input2:  args.shift,
      output_uri: args.shift
    )
  else
    puts <<~USAGE
      Usage: bundle exec ruby #{__FILE__} [command] [arguments]

      Commands:
      create_job_with_concatenated_inputs <location> <input1_uri>
        <start_time_input1> <end_time_input1> <input2_uri> <start_time_input2>
        <end_time_input2> <output_uri> Create a job with concatenated inputs

      Environment variables:
        GOOGLE_CLOUD_PROJECT    ID of the Google Cloud project to run snippets
    USAGE
  end
end
