# Changelog

### 0.12.1 (2025-07-15)

#### Documentation

* clarify documentation for cases when multiple parameters are mutually exclusive for an RPC method ([#30625](https://github.com/googleapis/google-cloud-ruby/issues/30625)) 

### 0.12.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 0.11.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 0.11.0 (2025-01-29)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.10.0 (2024-12-11)

#### Features

* Provide opt-in debug logging 

### 0.9.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.8.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 0.8.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24879](https://github.com/googleapis/google-cloud-ruby/issues/24879)) 

### 0.7.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.7.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.7.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23788](https://github.com/googleapis/google-cloud-ruby/issues/23788)) 

### 0.6.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22925](https://github.com/googleapis/google-cloud-ruby/issues/22925)) 

### 0.5.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.5.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21680](https://github.com/googleapis/google-cloud-ruby/issues/21680)) 

### 0.4.0 (2023-02-23)

#### Features

* Added support for REST transport ([#20498](https://github.com/googleapis/google-cloud-ruby/issues/20498)) 

### 0.3.0 (2022-08-09)

#### Features

* Added advanced OCR options to TextDetectionParams ([#18978](https://github.com/googleapis/google-cloud-ruby/issues/18978)) 

### 0.2.0 (2022-07-08)

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

### 0.1.0 / 2021-09-28

#### Features

* Initial generation of google-cloud-vision-v1p4beta1
