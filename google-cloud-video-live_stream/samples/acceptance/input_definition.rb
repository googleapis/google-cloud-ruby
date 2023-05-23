require "google/cloud/video/live_stream"

def input_def
  {
    type: Google::Cloud::Video::LiveStream::V1::Input::Type::RTMP_PUSH
  }
end
