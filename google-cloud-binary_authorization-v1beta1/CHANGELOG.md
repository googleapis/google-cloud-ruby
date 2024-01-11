# Release History

### 0.12.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23775](https://github.com/googleapis/google-cloud-ruby/issues/23775)) 

### 0.11.0 (2023-12-04)

#### Features

* Added container_name and container_type fields to ImageDetails ([#23568](https://github.com/googleapis/google-cloud-ruby/issues/23568)) 

### 0.10.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22918](https://github.com/googleapis/google-cloud-ruby/issues/22918)) 

### 0.9.0 (2023-08-15)

#### Features

* Added ContinuousValidationEvent::ContinuousValidationPodEvent::ImageDetails#check_results 
* Added ContinuousValidationEvent::ContinuousValidationPodEvent#policy_name 
* Added ContinuousValidationEvent#config_error_event ([#22780](https://github.com/googleapis/google-cloud-ruby/issues/22780)) 
#### Bug Fixes

* BREAKING: Removed ContinuousValidationEvent#unsupported_policy_event which was never used 

### 0.8.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21673](https://github.com/googleapis/google-cloud-ruby/issues/21673)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.7.0 (2023-03-08)

#### Features

* Support REST transport ([#20625](https://github.com/googleapis/google-cloud-ruby/issues/20625)) 

### 0.6.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.5.0 (2022-06-17)

#### Features

* Add a namespace field to pod events created by continuous validation

### 0.4.1 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.4.0 / 2021-11-11

#### Features

* Support for the SystemPolicy service

### 0.3.5 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.3.4 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.3.3 / 2021-08-05

#### Documentation

* Clarified descriptions of GlobalPolicyEvaluationMode values

### 0.3.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.3.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.3.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.2.1 / 2021-02-23

#### Documentation

* Replace "whitelist" with "allowlist" in generated documentation

### 0.2.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.1.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.0 / 2020-12-03

Initial release
