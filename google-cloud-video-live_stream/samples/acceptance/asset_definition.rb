require "google/cloud/video/live_stream"

def asset_def asset_uri
  {
    video: {
      uri: asset_uri
    }
  }
end
