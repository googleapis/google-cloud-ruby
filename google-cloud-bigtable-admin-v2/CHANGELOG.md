# Release History

### 0.21.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.21.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23775](https://github.com/googleapis/google-cloud-ruby/issues/23775)) 

### 0.20.0 (2024-01-03)

#### Features

* Modify ModifyColumnFamiliesRequest proto to expose ignore_warnings field ([#23665](https://github.com/googleapis/google-cloud-ruby/issues/23665)) 

### 0.19.0 (2023-10-16)

#### Features

* Add standard isolation options to AppProfile ([#23425](https://github.com/googleapis/google-cloud-ruby/issues/23425)) 

### 0.18.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22917](https://github.com/googleapis/google-cloud-ruby/issues/22917)) 

### 0.17.0 (2023-08-15)

#### Features

* Support for the copy_backup RPC ([#22783](https://github.com/googleapis/google-cloud-ruby/issues/22783)) 

### 0.16.3 (2023-08-04)

#### Documentation

* Improve documentation format ([#22684](https://github.com/googleapis/google-cloud-ruby/issues/22684)) 

### 0.16.2 (2023-07-10)

#### Documentation

* Increase the max backup retention period to 90 days ([#22465](https://github.com/googleapis/google-cloud-ruby/issues/22465)) 

### 0.16.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.16.0 (2023-05-31)

#### Features

* Support for enabling the change stream on a table ([#21683](https://github.com/googleapis/google-cloud-ruby/issues/21683)) 
* Uses binary protobuf definitions for better forward compatibility 

### 0.15.0 (2022-09-16)

#### Features

* Support for Table#deletion_protection 
* Support for update_table call ([#19149](https://github.com/googleapis/google-cloud-ruby/issues/19149)) 

### 0.14.0 (2022-07-28)

#### Features

* Support for the satisfies_pzs field on Instsance ([#18872](https://github.com/googleapis/google-cloud-ruby/issues/18872)) 

### 0.13.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.12.0 (2022-06-30)

#### Features

* Support for undelete_table 

### 0.11.0 (2022-05-19)

#### Features

* Include table info in CreateClusterMetadata
* Support the "name" parameter for update_instance and update_cluster

### 0.10.0 (2022-04-20)

#### Features

* Support for update masks when setting IAM policies

### 0.9.1 / 2022-03-31

#### Documentation

* Clarification on a few autoscaling and encryption fields

### 0.9.0 / 2022-03-30

#### Features

* Support for listing hot tablets

### 0.8.1 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.8.0 / 2021-12-07

#### Features

* Support for cluster autoscaling and partial updates

#### Bug Fixes

* Use the correct backend hostname by default

### 0.7.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.7.0 / 2021-10-25

#### Features

* Reports the creation time of instances

### 0.6.1 / 2021-08-30

#### Documentation

* Fix the links to the corresponding main client library

### 0.6.0 / 2021-08-20

#### Features

* Add MultiClusterRoutingUseAny#cluster_ids field

### 0.5.4 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.5.3 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.5.2 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.5.1 / 2021-05-19

#### Documentation

* Clarify that backup restores must be in the same project

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.4.0 / 2021-02-25

#### Features

* Support for Customer Managed Encryption Keys on clusters

### 0.3.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.2.1 / 2021-01-26

#### Bug Fixes

* Update default timeout and retry configuration

### 0.2.0 / 2020-10-29

#### Features

* Update GetIamPolicy to include the additional binding for Backup.
  * Change DeleteAppProfileRequest.ignore_warnings to REQUIRED.

### 0.1.2 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.1 / 2020-08-06

#### Bug Fixes

* Fix retries by converting error names to integer codes

### 0.1.0 / 2020-07-27

Initial release.
