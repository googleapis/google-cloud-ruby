# Release History

### 0.11.0 (2022-07-25)

#### Features

* Support for listing database roles ([#18849](https://github.com/googleapis/google-cloud-ruby/issues/18849)) 

### 0.10.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.9.0 (2022-04-20)

#### Features

* Support for update masks when setting IAM policies

### 0.8.0 / 2022-03-28

#### Features

* Add support for copy_backup

### 0.7.6 / 2022-03-17

#### Bug Fixes

* remove unused imports 

### 0.7.5 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.7.4 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.7.3 / 2021-08-30

#### Documentation

* Fix the links to the corresponding main client library

### 0.7.2 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.7.1 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.7.0 / 2021-07-07

#### Features

* Add default_leader field to Database type

### 0.6.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.6.0 / 2021-04-23

#### Features

* Added progress field to UpdateDatabaseDdlMetadata

### 0.5.1 / 2021-04-05

#### Documentation

* Correct the default encryption type documented in restore_database

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.4.0 / 2021-02-23

#### Features

* Add CMEK fields to backup and database

### 0.3.0 / 2021-02-02

#### Features

* Support point-in-time-recovery fields
* Use self-signed JWT credentials when possible

### 0.2.1 / 2021-01-20

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.0 / 2020-12-02

#### Features

* Add throttled field to database DDL metadata

### 0.1.3 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.2 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.1.1 / 2020-07-23

#### Bug Fixes

* Make the spanner env prefixes consistent
* Allow retries of UpdateBackup

### 0.1.0 / 2020-07-06

Initial release.
