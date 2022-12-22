require "google/cloud/video/stitcher"

def media_cdn_def cdn_key_path, hostname, key_name, private_key
  {
    name: cdn_key_path,
    hostname: hostname,
    media_cdn_key: {
      key_name: key_name,
      private_key: private_key
    }
  }
end
