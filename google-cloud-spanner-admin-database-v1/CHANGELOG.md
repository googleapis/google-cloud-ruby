# Release History

### 1.9.0 (2025-07-28)

#### Features

* proto changes for an internal api ([#30718](https://github.com/googleapis/google-cloud-ruby/issues/30718)) 

### 1.8.0 (2025-06-05)

#### Features

* Support throughput_mode in UpdateDatabaseDdlRequest to be used by Spanner Migration Tool 

### 1.7.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 1.6.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 1.6.0 (2025-02-13)

#### Features

* Backup resources now report the instance partitions storing the backup ([#29069](https://github.com/googleapis/google-cloud-ruby/issues/29069)) 

### 1.5.0 (2025-01-31)

#### Features

* Support for the add_split_points RPC ([#28794](https://github.com/googleapis/google-cloud-ruby/issues/28794)) 

### 1.4.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* fix typo in timezone ([#28248](https://github.com/googleapis/google-cloud-ruby/issues/28248)) 
* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 1.3.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 1.2.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` ([#27012](https://github.com/googleapis/google-cloud-ruby/issues/27012)) 

### 1.2.0 (2024-08-28)

#### Features

* Add resource reference annotation to backup schedules ([#26960](https://github.com/googleapis/google-cloud-ruby/issues/26960)) 
#### Documentation

* Add an example to filter backups based on schedule name 

### 1.1.1 (2024-08-08)

#### Documentation

* Formatting updates to README.md ([#26667](https://github.com/googleapis/google-cloud-ruby/issues/26667)) 

### 1.1.0 (2024-08-02)

#### Features

* Support for incremental backups ([#26546](https://github.com/googleapis/google-cloud-ruby/issues/26546)) 

### 1.0.0 (2024-07-08)

#### Features

* Bump version to 1.0.0 

### 0.20.0 (2024-07-08)

#### Features

* Add support for Cloud Spanner Scheduled Backups ([#26279](https://github.com/googleapis/google-cloud-ruby/issues/26279)) 

### 0.19.0 (2024-05-15)

#### Features

* Support kms key names and encryption information in backup configuration ([#25854](https://github.com/googleapis/google-cloud-ruby/issues/25854)) 

### 0.18.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24877](https://github.com/googleapis/google-cloud-ruby/issues/24877)) 

### 0.17.1 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.17.0 (2024-01-25)

#### Features

* Support proto descriptors when creating a database or getting or updating a database DDL ([#24468](https://github.com/googleapis/google-cloud-ruby/issues/24468)) 

### 0.16.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.16.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23786](https://github.com/googleapis/google-cloud-ruby/issues/23786)) 

### 0.15.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22924](https://github.com/googleapis/google-cloud-ruby/issues/22924)) 

### 0.14.2 (2023-08-04)

#### Documentation

* Improve documentation format ([#22685](https://github.com/googleapis/google-cloud-ruby/issues/22685)) 

### 0.14.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.14.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21678](https://github.com/googleapis/google-cloud-ruby/issues/21678)) 
* Added brief action info for DDL statements ([#21905](https://github.com/googleapis/google-cloud-ruby/issues/21905)) 

### 0.13.0 (2023-05-17)

#### Features

* Add support for UpdateDatabase in Spanner database admin 

### 0.12.0 (2023-03-08)

#### Features

* Support REST transport ([#20629](https://github.com/googleapis/google-cloud-ruby/issues/20629)) 

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
