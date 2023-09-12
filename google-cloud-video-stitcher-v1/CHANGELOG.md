# Changelog

### 0.7.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22925](https://github.com/googleapis/google-cloud-ruby/issues/22925)) 

### 0.6.2 (2023-09-05)

#### Documentation

* Minor clarifications ([#22825](https://github.com/googleapis/google-cloud-ruby/issues/22825)) 

### 0.6.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.6.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21679](https://github.com/googleapis/google-cloud-ruby/issues/21679)) 

### 0.5.0 (2023-04-28)

### ⚠ BREAKING CHANGES

* The create_cdn_key, delete_cdn_key, update_cdn_key, create_slate, delete_slate, and update_slate calls now return long-running operation handles
* Renamed client_ad_tracking fields to ad_tracking
* Moved source_uri, default_ad_tag_id, ad_tag_map, default_slate_id, and stitching_policy from LiveSession into the structure under live_config

#### Features

* Added Google Ad Manager attributes to Slate 
* Added Google Ad Manager metadata to session resources 
* Added request_id argument to create_slate 
* Added support for managing live configs ([#21012](https://github.com/googleapis/google-cloud-ruby/issues/21012)) 
#### Bug Fixes

* Moved source_uri, default_ad_tag_id, ad_tag_map, default_slate_id, and stitching_policy from LiveSession into the structure under live_config 
* Renamed client_ad_tracking fields to ad_tracking 
* The create_cdn_key, delete_cdn_key, update_cdn_key, create_slate, delete_slate, and update_slate calls now return long-running operation handles 

### 0.4.0 (2022-11-01)

#### Features

* Added support for Media CDN ([#19344](https://github.com/googleapis/google-cloud-ruby/issues/19344)) 

### 0.3.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.2.0 (2022-06-15)

### ⚠ BREAKING CHANGES

* Removed the COMPLETE_POD stitching policy (#18364)

#### Features

* Added asset_id to VodSession
* Added stream_id to LiveSession
#### Bug Fixes

* Removed the COMPLETE_POD stitching policy

### 0.1.0 / 2022-02-15

#### Features

* Initial generation of google-cloud-video-stitcher-v1
