# Changelog

### 0.6.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.6.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.6.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23789](https://github.com/googleapis/google-cloud-ruby/issues/23789)) 

### 0.5.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22926](https://github.com/googleapis/google-cloud-ruby/issues/22926)) 

### 0.4.0 (2023-09-04)

#### Features

* Add support for REST transport ([#22795](https://github.com/googleapis/google-cloud-ruby/issues/22795)) 
* Support for the LOG_NONE logging level 
* Support for the UNAVAILABLE and QUEUED states 
* The Execution resource now includes duration, status, labels, and state_error fields 
* The list_executions call now supports filtering and ordering 

### 0.3.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.3.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21680](https://github.com/googleapis/google-cloud-ruby/issues/21680)) 

### 0.2.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.1.2 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.1.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.1.0 / 2021-09-27

#### Features

* Initial generation of google-cloud-workflows-executions-v1
