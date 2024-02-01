# Release History

### 0.15.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.15.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.15.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23783](https://github.com/googleapis/google-cloud-ruby/issues/23783)) 

### 0.14.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22922](https://github.com/googleapis/google-cloud-ruby/issues/22922)) 

### 0.13.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21677](https://github.com/googleapis/google-cloud-ruby/issues/21677)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.12.0 (2023-03-08)

#### Features

* Support REST transport ([#20627](https://github.com/googleapis/google-cloud-ruby/issues/20627)) 

### 0.11.0 (2022-07-06)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.10.0 (2022-04-15)

#### Features

* Support for pause patch deployment, resume patch deployment, update patch deployment

### 0.9.1 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.9.0 / 2021-12-07

#### Features

* Return the list of items affected by a vulnerability

### 0.8.0 / 2021-11-08

#### Features

* Support for OS policy assignments

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.7.0 / 2021-10-21

#### Features

* Support daily frequency for recurring patch deployments

### 0.6.0 / 2021-09-07

#### Features

* Support OsConfigZonalService including inventory and vulnerability report calls

### 0.5.0 / 2021-08-31

#### Features

* Support Windows applications in the software package inventory

### 0.4.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.4.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.4.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.4.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.3.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.2.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.0 / 2020-11-19

#### Features

* Support for patch rollout strategy

### 0.1.4 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.3 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.1.2 / 2020-06-25

#### Documentation

* Fix several broken links in the reference documentation

### 0.1.1 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.1.0 / 2020-06-15

Initial release.
