# Release History

### 0.7.0 (2022-09-16)

#### Features

* Support for the locations client ([#19141](https://github.com/googleapis/google-cloud-ruby/issues/19141)) 

### 0.6.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.5.0 (2022-05-29)

#### Features

* support appengineIntegrationMode and key_prefix in database
* support TTL config

### 0.4.0 / 2022-01-11

#### Features

* Support for get_database, list_databases, and update_database operations

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.3.5 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.3.4 / 2021-08-30

#### Documentation

* Fix the links to the corresponding main client library

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

### 0.1.3 / 2021-01-20

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.2 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.1 / 2020-08-06

#### Bug Fixes

* Fix retries by converting error names to integer codes

### 0.1.0 / 2020-07-27

Initial release.
