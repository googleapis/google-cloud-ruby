# Release History

### 0.15.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24870](https://github.com/googleapis/google-cloud-ruby/issues/24870)) 

### 0.14.3 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.14.2 (2024-01-15)

#### Documentation

* Minor formatting fix ([#24411](https://github.com/googleapis/google-cloud-ruby/issues/24411)) 

### 0.14.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.14.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23779](https://github.com/googleapis/google-cloud-ruby/issues/23779)) 

### 0.13.0 (2024-01-03)

#### Features

* add DeleteDatabase API and delete protection ([#23683](https://github.com/googleapis/google-cloud-ruby/issues/23683)) 
#### Documentation

* update Database API description 

### 0.12.0 (2023-12-08)

#### Features

* Support database version retention and point-in-time-recovery 
* Support namespace_ids and snapshot_time parameters to export_documents RPC 
* Support namespace_ids parameter to import_documents RPC 

### 0.11.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22920](https://github.com/googleapis/google-cloud-ruby/issues/22920)) 

### 0.10.0 (2023-06-06)

#### Features

* Support for create_database ([#22073](https://github.com/googleapis/google-cloud-ruby/issues/22073)) 
* Uses binary protobuf definitions for better forward compatibility ([#21675](https://github.com/googleapis/google-cloud-ruby/issues/21675)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.9.0 (2023-05-19)

#### Features

* add ApiScope and COLLECTION_RECURSIVE query_scope for Firestore index 

### 0.8.0 (2023-03-08)

#### Features

* Support REST transport ([#20626](https://github.com/googleapis/google-cloud-ruby/issues/20626)) 

### 0.7.1 (2023-01-15)

#### Documentation

* Reference the correct main client gem name ([#19994](https://github.com/googleapis/google-cloud-ruby/issues/19994)) 

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
