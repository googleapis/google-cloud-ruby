# Changelog

### 0.13.0 (2024-04-19)

#### Features

* Support encoding format in CaPool resource ([#25465](https://github.com/googleapis/google-cloud-ruby/issues/25465)) 

### 0.12.0 (2024-03-18)

#### Features

* Add support for fine-grained maximum certificate lifetime controls ([#25372](https://github.com/googleapis/google-cloud-ruby/issues/25372)) 
#### Documentation

* Improve documentation ([#25372](https://github.com/googleapis/google-cloud-ruby/issues/25372)) 

### 0.11.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24876](https://github.com/googleapis/google-cloud-ruby/issues/24876)) 

### 0.10.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.10.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.10.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23785](https://github.com/googleapis/google-cloud-ruby/issues/23785)) 

### 0.9.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22923](https://github.com/googleapis/google-cloud-ruby/issues/22923)) 

### 0.8.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.8.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21678](https://github.com/googleapis/google-cloud-ruby/issues/21678)) 

### 0.7.0 (2023-04-10)

#### Features

* added ignore_dependent_resources to DeleteCaPoolRequest, DeleteCertificateAuthorityRequest, DisableCertificateAuthorityRequest ([#21052](https://github.com/googleapis/google-cloud-ruby/issues/21052)) 

### 0.6.0 (2023-03-08)

#### Features

* Support REST transport ([#20628](https://github.com/googleapis/google-cloud-ruby/issues/20628)) 

### 0.5.0 (2023-02-14)

#### Features

* Support for X.509 name constraints ([#20406](https://github.com/googleapis/google-cloud-ruby/issues/20406)) 

### 0.4.0 (2022-07-07)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.3.0 (2022-05-13)

#### Features

* Provide interfaces for location and IAM policy calls

### 0.2.1 (2022-04-20)

#### Bug Fixes

* Update grpc-google-iam-v1 dependency to 1.1

### 0.2.0 / 2022-03-24

#### Features

* Support to skip grace period to delete Certificate Authority

### 0.1.6 / 2022-02-15

#### Bug Fixes

* Set quota project on long-running operations calls

### 0.1.5 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.1.4 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.1.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.1.2 / 2021-07-21

#### Documentation

* Various corrections to data type field documentation

### 0.1.1 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.1.0 / 2021-06-21

#### Features

* Initial generation of google-cloud-security-private_ca-v1
