# Release History

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
