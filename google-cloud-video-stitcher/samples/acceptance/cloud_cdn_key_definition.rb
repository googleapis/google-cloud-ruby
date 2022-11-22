require "google/cloud/video/stitcher"

def cloud_cdn_def cdn_key_path, hostname, gcdn_keyname, gcdn_private_key
  {
    name: cdn_key_path,
    hostname: hostname,
    google_cdn_key: {
      key_name: gcdn_keyname,
      private_key: gcdn_private_key
    }
  }
end
