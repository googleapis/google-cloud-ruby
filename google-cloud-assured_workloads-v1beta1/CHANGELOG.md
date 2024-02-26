# Release History

### 0.18.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24863](https://github.com/googleapis/google-cloud-ruby/issues/24863)) 

### 0.17.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.17.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.17.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23773](https://github.com/googleapis/google-cloud-ruby/issues/23773)) 

### 0.16.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22916](https://github.com/googleapis/google-cloud-ruby/issues/22916)) 

### 0.15.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21671](https://github.com/googleapis/google-cloud-ruby/issues/21671)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.14.0 (2023-03-08)

#### Features

* Support REST transport ([#20624](https://github.com/googleapis/google-cloud-ruby/issues/20624)) 

### 0.13.0 (2022-09-07)

#### Features

* add compliant_but_disallowed_services to Workload 
#### Documentation

* update auth doc with application-default 

### 0.12.0 (2022-08-25)

#### Features

* Added Australia Regions compliance regime

#### Bug Fixes

* BREAKING CHANGE: Removed restrict_allowed_services call

### 0.11.0 (2022-07-25)

#### Features

* Support for a new call analyzing whether a workload can be moved 
* Support for new calls for restricting services and resources allowed in the workload environment ([#18845](https://github.com/googleapis/google-cloud-ruby/issues/18845)) 

### 0.10.0 (2022-07-01)

#### Features

* Support for the ITAR compliance regime 
* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.9.2 (2022-06-15)

#### Bug Fixes

* Renamed some internal protobuf definition files

### 0.9.1 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.9.0 / 2021-12-10

#### Features

* EU Regions and Support With Sovereign Controls

### 0.8.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.8.0 / 2021-08-30

#### Features

* Support resource display names and additional resource types

### 0.7.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.7.0 / 2021-07-29

#### Features

* Support the EU_REGIONS_AND_SUPPORT compliance regime

### 0.6.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 0.6.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.6.0 / 2021-03-30

#### Features

* Add 'resource_settings' field to provide custom properties (ids) for the provisioned projects.
* Add HIPAA and HITRUST compliance regimes

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.4.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.3.0 / 2021-01-26

#### Features

* Added US regional compliance regime

### 0.2.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.0 / 2020-11-19

#### Features

* Support workload kms settings and provisioned resource parents

### 0.1.0 / 2020-09-18

Initial release.
