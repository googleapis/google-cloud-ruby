require "google/cloud/video/stitcher"

def vod_session_def source_uri, ad_tag_uri
  {
    source_uri: source_uri,
    ad_tag_uri: ad_tag_uri
  }
end
