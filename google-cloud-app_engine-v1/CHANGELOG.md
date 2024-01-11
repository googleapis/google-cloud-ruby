# Release History

### 0.9.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23773](https://github.com/googleapis/google-cloud-ruby/issues/23773)) 

### 0.8.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22916](https://github.com/googleapis/google-cloud-ruby/issues/22916)) 

### 0.7.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21671](https://github.com/googleapis/google-cloud-ruby/issues/21671)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.6.1 (2023-04-03)

#### Documentation

* point to Search Console for domain ownership verification ([#21049](https://github.com/googleapis/google-cloud-ruby/issues/21049)) 

### 0.6.0 (2023-03-08)

#### Features

* Support REST transport ([#20624](https://github.com/googleapis/google-cloud-ruby/issues/20624)) 

### 0.5.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.4.0 (2022-05-06)

#### Features

* Added the labels field to the Service data type
* Added the service_account field to the Application data type
* Allow second generation runtimes to access legacy bundled services
* Support the egress setting for a VPC access connector

### 0.3.6 / 2022-02-18

#### Bug Fixes

* Clean up some unused requires

### 0.3.5 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

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

* Clarified some language around authentication configuration

### 0.3.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.3.0 / 2021-03-24

#### Features

* Support service network settings, build environment variables, additional security settings, and VM liveness queries.

### 0.2.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.1.0 / 2021-02-24

* Initial release.
