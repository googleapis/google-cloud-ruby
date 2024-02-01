# Changelog

### 0.9.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.9.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.9.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23773](https://github.com/googleapis/google-cloud-ruby/issues/23773)) 

### 0.8.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22916](https://github.com/googleapis/google-cloud-ruby/issues/22916)) 

### 0.7.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21671](https://github.com/googleapis/google-cloud-ruby/issues/21671)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.6.0 (2023-03-08)

#### Features

* Support REST transport ([#20624](https://github.com/googleapis/google-cloud-ruby/issues/20624)) 

### 0.5.0 (2022-10-18)

#### Features

* add new field for exception audit log link ([#19282](https://github.com/googleapis/google-cloud-ruby/issues/19282)) 

### 0.4.0 (2022-10-03)

#### Features

* Support for acknowledging an existing violation 
* Support for listing the violations in the workload environment 
* Support for restricting thie list of resources allowed in the workload environment ([#19243](https://github.com/googleapis/google-cloud-ruby/issues/19243)) 
* Support for retrieving an assured workload violation by ID 

### 0.3.0 (2022-07-01)

#### Features

* Support for the ITAR compliance regime 
* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.2.1 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.2.0 / 2021-12-10

#### Features

* EU Regions and Support With Sovereign Controls

### 0.1.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.1.0 / 2021-09-27

#### Features

* Initial generation of google-cloud-assured_workloads-v1
