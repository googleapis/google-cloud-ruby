# Copyright 2022 Google, Inc
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

# [START livestream_create_channel]
require "google/cloud/video/live_stream"

##
# Create a channel
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location [String] The location (e.g. "us-central1")
# @param channel_id [String] Your channel name (e.g. "my-channel")
# @param input_id [String] Your input name (e.g. "my-input")
# @param output_uri [String] Uri of the channel output folder in a Cloud Storage
#     bucket. (e.g. "gs://my-bucket/my-output-folder/";)
#
def create_channel project_id:, location:, channel_id:, input_id:, output_uri:
  # Create a Live Stream client.
  client = Google::Cloud::Video::LiveStream.livestream_service

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location
  # Build the resource name of the input.
  input_path = client.input_path project: project_id, location: location, input: input_id

  # Set the channel fields.
  new_channel = {
    input_attachments: [
      {
        key: "my-input",
        input: input_path
      }
    ],
    output: {
      uri: output_uri
    },
    elementary_streams: [
      {
        key: "es_video",
        video_stream: {
          h264: {
            profile: "high",
            bitrate_bps: 3_000_000,
            frame_rate: 30,
            height_pixels: 720,
            width_pixels: 1280
          }
        }
      },
      {
        key: "es_audio",
        audio_stream: {
          codec: "aac",
          channel_count: 2,
          bitrate_bps: 160_000
        }
      }
    ],
    mux_streams: [
      {
        key: "mux_video",
        elementary_streams: [
          "es_video"
        ],
        segment_settings: {
          segment_duration: {
            seconds: 2
          }
        }
      },
      {
        key: "mux_audio",
        elementary_streams: [
          "es_audio"
        ],
        segment_settings: {
          segment_duration: {
            seconds: 2
          }
        }
      }
    ],
    manifests: [
      {
        file_name: "main.m3u8",
        type: Google::Cloud::Video::LiveStream::V1::Manifest::ManifestType::HLS,
        mux_streams: [
          "mux_video", "mux_audio"
        ],
        max_segment_count: 5
      }
    ]
  }

  operation = client.create_channel parent: parent, channel: new_channel, channel_id: channel_id

  # The returned object is of type Gapic::Operation. You can use this
  # object to check the status of an operation, cancel it, or wait
  # for results. Here is how to block until completion:
  operation.wait_until_done!

  # Print the channel name.
  puts "Channel: #{operation.response.name}"
end
# [END livestream_create_channel]
