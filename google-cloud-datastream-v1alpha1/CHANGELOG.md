# Changelog

### 0.11.1 (2025-07-15)

#### Documentation

* Clarify documentation for cases when multiple parameters are mutually exclusive for an RPC method ([#30624](https://github.com/googleapis/google-cloud-ruby/issues/30624)) 

### 0.11.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 0.10.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 0.10.0 (2025-02-07)

### ⚠ BREAKING CHANGES

* Fixed incorrect pagination on certain REST RPC methods ([#28824](https://github.com/googleapis/google-cloud-ruby/issues/28824))

#### Bug Fixes

* Fixed incorrect pagination on certain REST RPC methods ([#28824](https://github.com/googleapis/google-cloud-ruby/issues/28824)) 

### 0.9.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.8.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.7.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 0.7.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24869](https://github.com/googleapis/google-cloud-ruby/issues/24869)) 

### 0.6.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.6.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.6.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23778](https://github.com/googleapis/google-cloud-ruby/issues/23778)) 

### 0.5.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22919](https://github.com/googleapis/google-cloud-ruby/issues/22919)) 

### 0.4.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21674](https://github.com/googleapis/google-cloud-ruby/issues/21674)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.3.0 (2023-03-08)

#### Features

* Support REST transport ([#20626](https://github.com/googleapis/google-cloud-ruby/issues/20626)) 

### 0.2.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.1.2 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.1.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.1.0 / 2021-08-31

#### Features

* Initial generation of google-cloud-datastream-v1alpha1
