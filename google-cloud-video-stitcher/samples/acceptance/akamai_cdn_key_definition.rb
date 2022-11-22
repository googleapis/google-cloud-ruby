require "google/cloud/video/stitcher"

def akamai_cdn_def cdn_key_path, hostname, akamai_token_key
  {
    name: cdn_key_path,
    hostname: hostname,
    akamai_cdn_key: {
      token_key: akamai_token_key
    }
  }
end
