# Release History

### 0.4.2 / 2022-01-11

#### Bug Fixes

* Increase call timeouts to 5 minutes

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.4.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.4.0 / 2021-09-07

#### Features

* Support setting the ID in create_capacity_commitment and create_assignment
* Support for force-deleting capacity commitments
* Deprecated search_assignments call and added search_all_assignments as replacement
* Added creation and update time fields to Reservation
* Added start time field to CapacityCommitment
* Added ML_EXTERNAL job type

#### Bug Fixes

* Update RPC timeout settings
* Fixed a typo in the paths returned by the bi_reservation_path helper

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

* Fix retry logic by checking the correct numeric error codes

### 0.1.0 / 2020-06-25

Initial release.
