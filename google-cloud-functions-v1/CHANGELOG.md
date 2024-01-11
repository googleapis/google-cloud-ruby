# Release History

### 0.13.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23779](https://github.com/googleapis/google-cloud-ruby/issues/23779)) 

### 0.12.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22920](https://github.com/googleapis/google-cloud-ruby/issues/22920)) 

### 0.11.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21675](https://github.com/googleapis/google-cloud-ruby/issues/21675)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.10.0 (2023-05-16)

#### Features

* added helper methods for long running operations, IAM, and locations 
#### Documentation

* apply general style guide updates to descriptions 
* clarify that vpcConnector shortname is only returned if the connector is in the same project as the function 

### 0.9.0 (2023-03-08)

#### Features

* Support REST transport ([#20626](https://github.com/googleapis/google-cloud-ruby/issues/20626)) 

### 0.8.1 (2023-02-17)

#### Bug Fixes

* Fixed routing headers sent with long-running operation calls ([#20449](https://github.com/googleapis/google-cloud-ruby/issues/20449)) 

### 0.8.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.7.0 (2022-06-08)

#### Features

* Added support for CMEK

### 0.6.0 (2022-04-20)

#### Features

* Support for update masks when setting IAM policies

### 0.5.1 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.5.0 / 2021-11-08

#### Features

* Support for build environment variables, min instances, and secret manager and CMEK integration

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.4.0 / 2021-09-22

#### Features

* Added security level to the https trigger

### 0.3.3 / 2021-08-19

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

#### Bug Fixes

* Fixed timeout and retry settings

### 0.2.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.1.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.0 / 2020-09-10

Initial release.
