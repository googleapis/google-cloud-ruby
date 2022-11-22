# Release History

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
