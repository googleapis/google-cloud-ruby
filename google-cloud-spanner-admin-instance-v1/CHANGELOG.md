# Release History

### 0.13.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.13.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.13.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23786](https://github.com/googleapis/google-cloud-ruby/issues/23786)) 

### 0.12.0 (2023-10-17)

#### Features

* add autoscaling config to the admin instance ([#23436](https://github.com/googleapis/google-cloud-ruby/issues/23436)) 

### 0.11.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22924](https://github.com/googleapis/google-cloud-ruby/issues/22924)) 

### 0.10.2 (2023-08-04)

#### Documentation

* Improve documentation format ([#22685](https://github.com/googleapis/google-cloud-ruby/issues/22685)) 

### 0.10.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.10.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21678](https://github.com/googleapis/google-cloud-ruby/issues/21678)) 

### 0.9.0 (2023-03-08)

#### Features

* Support REST transport ([#20629](https://github.com/googleapis/google-cloud-ruby/issues/20629)) 

### 0.8.0 (2022-09-16)

#### Features

* Support for managing instance configs ([#19172](https://github.com/googleapis/google-cloud-ruby/issues/19172)) 

### 0.7.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
* Add new fields for Instance create_time and update_time ([#18666](https://github.com/googleapis/google-cloud-ruby/issues/18666)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.6.0 (2022-04-20)

#### Features

* Support for update masks when setting IAM policies

### 0.5.5 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.5.4 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.5.3 / 2021-08-30

#### Documentation

* Fix the links to the corresponding main client library

### 0.5.2 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.5.1 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.5.0 / 2021-07-07

#### Features

* Add leader_options field to InstanceConfig type

### 0.4.0 / 2021-06-17

#### Features

* Add processing_units to the Instance resource

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.3.1 / 2021-04-05

#### Documentation

* Mark Instance#state as read-only

### 0.3.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.2.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.1.4 / 2021-01-20

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.3 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.2 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.1.1 / 2020-07-23

#### Bug Fixes

* Make the spanner env prefixes consistent

### 0.1.0 / 2020-07-06

Initial release.
