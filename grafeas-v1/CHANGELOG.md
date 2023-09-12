# Release History

### 0.13.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22926](https://github.com/googleapis/google-cloud-ruby/issues/22926)) 

### 0.12.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.12.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21681](https://github.com/googleapis/google-cloud-ruby/issues/21681)) 

### 0.11.0 (2023-05-04)

#### Features

* Added support for bulk writer ([#21426](https://github.com/googleapis/google-cloud-ruby/issues/21426)) 

### 0.10.0 (2023-04-16)

#### Features

* Update AttackComplexity and Authentication enums 

### 0.9.0 (2023-03-15)

#### Features

* Add vulnerability assessment options ([#20892](https://github.com/googleapis/google-cloud-ruby/issues/20892)) 

### 0.8.0 (2023-03-05)

#### Features

* Report the CVSS V2 score for a vulnerability ([#20597](https://github.com/googleapis/google-cloud-ruby/issues/20597)) 

### 0.7.0 (2022-10-03)

#### Features

* add new analysis status and cvss version fields ([#19238](https://github.com/googleapis/google-cloud-ruby/issues/19238)) 

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
