# Release History

### 0.12.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.12.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23781](https://github.com/googleapis/google-cloud-ruby/issues/23781)) 

### 0.11.0 (2023-09-29)

#### Features

* support endpoint_location for Consumer 

### 0.10.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22921](https://github.com/googleapis/google-cloud-ruby/issues/22921)) 

### 0.9.0 (2023-07-10)

#### Features

* added Admin Interface (v1) ([#22478](https://github.com/googleapis/google-cloud-ruby/issues/22478)) 
* added BigQuery as a backend metastore (v1) 
* added gRPC endpoint protocol (v1) 

### 0.8.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.8.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21676](https://github.com/googleapis/google-cloud-ruby/issues/21676)) 

### 0.7.0 (2023-04-20)

#### Features

* Support Common Expression Language ([#21441](https://github.com/googleapis/google-cloud-ruby/issues/21441)) 
* Support Scaling configuration ([#21441](https://github.com/googleapis/google-cloud-ruby/issues/21441)) 

### 0.6.0 (2023-03-08)

#### Features

* Support REST transport ([#20627](https://github.com/googleapis/google-cloud-ruby/issues/20627)) 

### 0.5.0 (2023-02-17)

#### Features

* Include the location and iam_policy mixin clients ([#20456](https://github.com/googleapis/google-cloud-ruby/issues/20456)) 

### 0.4.0 (2022-12-06)

#### Features

* Added support for encryption, network, database type, and telemetry configuration in a Metastore Service 
* Added support for Federations ([#19473](https://github.com/googleapis/google-cloud-ruby/issues/19473)) 

### 0.3.0 (2022-07-05)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.2.2 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.2.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.2.0 / 2021-08-19

#### Features

* Support for backups and restores

### 0.1.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.1.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.1.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.1.0 / 2021-03-30

* Initial release
