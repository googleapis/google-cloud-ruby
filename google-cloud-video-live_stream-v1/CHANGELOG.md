# Changelog

### 0.8.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.8.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.8.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23787](https://github.com/googleapis/google-cloud-ruby/issues/23787)) 

### 0.7.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22925](https://github.com/googleapis/google-cloud-ruby/issues/22925)) 

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
