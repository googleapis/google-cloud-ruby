# Release History

### 0.15.2 (2024-10-15)

#### Documentation

* Minor wording and branding adjustments ([#27423](https://github.com/googleapis/google-cloud-ruby/issues/27423)) 

### 0.15.1 (2024-09-11)

#### Documentation

* Minor documentation updates ([#27302](https://github.com/googleapis/google-cloud-ruby/issues/27302)) 

### 0.15.0 (2024-08-30)

#### Features

* add AssessmentEnvironment for CreateAssessement to explicitly describe the environment of the assessment 
#### Documentation

* Add field `experimental_features` to message `PythonSettings` 
* Add field `experimental_features` to message `PythonSettings` ([#27011](https://github.com/googleapis/google-cloud-ruby/issues/27011)) 
* minor doc fixes 

### 0.14.0 (2024-04-25)

#### Features

* Support for fraud prevention settings ([#25762](https://github.com/googleapis/google-cloud-ruby/issues/25762)) 

### 0.13.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24875](https://github.com/googleapis/google-cloud-ruby/issues/24875)) 

### 0.12.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.12.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.12.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23784](https://github.com/googleapis/google-cloud-ruby/issues/23784)) 

### 0.11.0 (2024-01-09)

#### Features

* Added behavioral trust verdict to FraudPreventionAssessment ([#23423](https://github.com/googleapis/google-cloud-ruby/issues/23423)) 

### 0.10.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22923](https://github.com/googleapis/google-cloud-ruby/issues/22923)) 

### 0.9.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.9.0 (2023-06-01)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21677](https://github.com/googleapis/google-cloud-ruby/issues/21677)) 

### 0.8.0 (2023-03-23)

#### Features

* Add support for reCAPTCHA Enterprise FraudPrevention API 
* Add support for reCAPTCHA Enterprise TransactionData API 
* Add support for TransactionEvent ([#20923](https://github.com/googleapis/google-cloud-ruby/issues/20923)) 

### 0.7.0 (2023-03-08)

#### Features

* Support REST transport ([#20628](https://github.com/googleapis/google-cloud-ruby/issues/20628)) 

### 0.6.0 (2022-07-07)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.5.0 (2022-05-03)

#### Features

* Support Account Defender assessments
* Support password leak verification
* Support providing a hashed account ID with an assessment annotation
* Support providing a reason for an assessment annotation

#### Bug Fixes

* BREAKING CHANGE: Removed unsupported key management API

### 0.4.5 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.4.4 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

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

### 0.2.5 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.4 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.2.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.2.2 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.2.1 / 2020-05-26

#### Documentation

* Use the preferred service name in the client docs

### 0.2.0 / 2020-05-21

#### Features

* The quota_project can be set via configuration

### 0.1.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.1.0 / 2020-04-23

Initial release.
