require "google/cloud/video/live_stream"

def channel_def input_path, output_uri
  {
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
end
