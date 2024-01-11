# Release History

### 0.10.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23786](https://github.com/googleapis/google-cloud-ruby/issues/23786)) 

### 0.9.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22924](https://github.com/googleapis/google-cloud-ruby/issues/22924)) 

### 0.8.0 (2023-07-26)

#### Features

* support method_policies and field_policies 

### 0.7.0 (2023-06-27)

#### Features

* Support overriding of bindings ([#22452](https://github.com/googleapis/google-cloud-ruby/issues/22452)) 
#### Documentation

* Update docs for Field Mask & Expressions ([#22452](https://github.com/googleapis/google-cloud-ruby/issues/22452)) 

### 0.6.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.6.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21678](https://github.com/googleapis/google-cloud-ruby/issues/21678)) 

### 0.5.0 (2023-03-08)

#### Features

* Support REST transport ([#20629](https://github.com/googleapis/google-cloud-ruby/issues/20629)) 

### 0.4.1 (2023-02-17)

#### Bug Fixes

* Fixed routing headers sent with long-running operation calls ([#20450](https://github.com/googleapis/google-cloud-ruby/issues/20450)) 

### 0.4.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.3.10 (2022-04-22)

#### Documentation

* fix broken links

### 0.3.9 (2022-04-21)

#### Documentation

* update broken link for Google service management and format docs

### 0.3.8 / 2022-04-01

#### Documentation

* Remove redundant "API" in the service name

### 0.3.7 / 2022-02-17

#### Bug Fixes

* **BREAKING CHANGE:** Removed enable_service and disable_service client methods because those calls are no longer part of the API

#### Performance Improvements

* Removed some unused requires

### 0.3.6 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.3.5 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.3.4 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.3.3 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.3.2 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.3.1 / 2021-04-06

#### Documentation

* Fixed several broken links in the reference documentation

### 0.3.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.2.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.1.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.0 / 2020-12-04

Initial release
