# Release History

#### Documentation

* Clarify Finding#event_time description

### 0.13.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.13.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23785](https://github.com/googleapis/google-cloud-ruby/issues/23785)) 

### 0.12.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22923](https://github.com/googleapis/google-cloud-ruby/issues/22923)) 

### 0.11.2 (2023-08-04)

#### Documentation

* Improve documentation format ([#22685](https://github.com/googleapis/google-cloud-ruby/issues/22685)) 

### 0.11.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.11.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21678](https://github.com/googleapis/google-cloud-ruby/issues/21678)) 

### 0.10.0 (2023-03-08)

#### Features

* Support REST transport ([#20629](https://github.com/googleapis/google-cloud-ruby/issues/20629)) 

### 0.9.0 (2022-07-07)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.8.0 (2022-04-20)

#### Features

* Support for update masks when setting IAM policies

### 0.7.5 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.7.4 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.7.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.7.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.7.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.7.0 / 2021-05-18

#### Features

* Support for folder information and asset canonical names

### 0.6.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.5.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.4.2 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.4.1 / 2020-09-24

#### Documentation

* Updated description of Finding#severity field

### 0.4.0 / 2020-09-03

#### Features

* Support Finding#severity field

#### Documentation

* Clarify Finding#event_time description

### 0.3.4 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.3.3 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.3.2 / 2020-07-16

#### Bug Fixes

* Update timeout settings

### 0.3.1 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.3.0 / 2020-06-12

#### Features

* Provide resource information in notifications.

### 0.2.2 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.2.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file
* The long-running operations client honors the quota_project config

### 0.2.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.1.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.1.0 / 2020-04-23

Initial release.
