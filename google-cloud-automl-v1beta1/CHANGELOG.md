# Release History

### 0.14.1 (2025-07-15)

#### Documentation

* clarify documentation for cases when multiple parameters are mutually exclusive for an RPC method ([#30623](https://github.com/googleapis/google-cloud-ruby/issues/30623)) 

### 0.14.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 0.13.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 0.13.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.12.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.11.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 0.11.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24863](https://github.com/googleapis/google-cloud-ruby/issues/24863)) 

### 0.10.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.10.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.10.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23773](https://github.com/googleapis/google-cloud-ruby/issues/23773)) 

### 0.9.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22917](https://github.com/googleapis/google-cloud-ruby/issues/22917)) 

### 0.8.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21671](https://github.com/googleapis/google-cloud-ruby/issues/21671)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.7.0 (2023-03-08)

#### Features

* Support REST transport ([#20624](https://github.com/googleapis/google-cloud-ruby/issues/20624)) 

### 0.6.1 (2023-02-17)

#### Bug Fixes

* Fixed routing header sent with long-running operation calls ([#20448](https://github.com/googleapis/google-cloud-ruby/issues/20448)) 

### 0.6.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.5.5 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.5.4 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.5.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.5.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.5.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.4.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.3.2 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.3.1 / 2020-12-08

#### Bug Fixes

* Set version constants in the correct modules

### 0.3.0 / 2020-10-14

#### Features

* Added text extraction health care option in create model

### 0.2.6 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.2.5 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.2.4 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.2.3 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.2.2 / 2020-05-28

#### Documentation

* Fix a few broken links

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

### 0.1.0 / 2020-04-24

Initial release.
