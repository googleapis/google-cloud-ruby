# Release History

### 0.6.1 (2022-07-27)

* No significant updates

### 0.6.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.5.0 (2022-06-14)

#### Features

* Added a number of fields, including package type, CPE URI, and architecture, to the PackageNoteand PackageOccurrence data structures
* Added benchmark document name field to ComplianceVersion
* Added file location field to the PackageIssue data structure
* Added support for SLSA provenance version 0.2
#### Bug Fixes

* Deprecated the CPE URI from the Location data structure

### 0.4.0 / 2022-01-13

#### Features

* BREAKING CHANGE: Changed the type of VulnerabilityOccurrence#cvssv3 to a generalized CVSS Score data type that can cover multiple CVSS versions.
* Added DiscoveryOccurrence#archive_time, providing the time when occurrences were archived.

### 0.3.1 / 2022-01-11

#### Documentation

* Fix titles of documentation pages

### 0.3.0 / 2021-11-08

#### Features

* Support compliance and in-toto attestation

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.2.2 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.2.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.2.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.1.4 / 2021-02-02

#### Documentation

* Update readme to clarify the difference between this library and grafeas

### 0.1.3 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.2 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credential values

### 0.1.1 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.1.0 / 2020-06-03

Initial release
