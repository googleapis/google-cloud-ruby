require "google/cloud/video/stitcher"

def live_session_def source_uri, ad_tag_uri, slate_id
  {
    source_uri: source_uri,
    ad_tag_map: {
      default: {
        uri: ad_tag_uri
      }
    },
    default_slate_id: slate_id
  }
end
