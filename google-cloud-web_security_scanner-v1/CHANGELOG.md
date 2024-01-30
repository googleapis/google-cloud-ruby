# Release History

### 0.9.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.9.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23789](https://github.com/googleapis/google-cloud-ruby/issues/23789)) 

### 0.8.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22926](https://github.com/googleapis/google-cloud-ruby/issues/22926)) 

### 0.7.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.7.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21680](https://github.com/googleapis/google-cloud-ruby/issues/21680)) 

### 0.6.0 (2023-03-08)

#### Features

* Support REST transport ([#20630](https://github.com/googleapis/google-cloud-ruby/issues/20630)) 

### 0.5.0 (2022-09-08)

#### Features

* add ignore_http_status_errors to ScanConfig 
* add NO_STARTING_URL_FOUND_FOR_MANAGED_SCAN to scanRunWarningTrace 
* add xxe to Finding in WebSecurityScanner 

### 0.4.1 (2022-08-31)

#### Documentation

* Include reference documentation for ScanRunLog ([#19089](https://github.com/googleapis/google-cloud-ruby/issues/19089)) 

### 0.4.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.3.5 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.3.4 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.3.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.3.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.3.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.3.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.2.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.1.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.0 / 2020-12-03

Initial release
