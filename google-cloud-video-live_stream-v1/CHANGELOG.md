# Changelog

### 0.6.0 (2023-07-25)

#### Features

* support asset resource service and poll service 

### 0.5.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.5.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21679](https://github.com/googleapis/google-cloud-ruby/issues/21679)) 

### 0.4.0 (2023-03-21)

#### Features

* added Encryption for enabling output encryption with DRM systems 
* added InputConfig to allow enabling/disabling automatic failover 
* added new tasks to Event: inputSwitch, returnToProgram, mute, unmute 
* added support for audio normalization and audio gain 
* Added support for TimecodeConfig ([#20953](https://github.com/googleapis/google-cloud-ruby/issues/20953)) 
#### Documentation

* clarify behavior when update_mask is omitted in PATCH requests 

### 0.3.0 (2023-03-08)

#### Features

* Support REST transport ([#20629](https://github.com/googleapis/google-cloud-ruby/issues/20629)) 

### 0.2.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.1.0 / 2022-02-15

#### Features

* Initial generation of google-cloud-video-live_stream-v1
