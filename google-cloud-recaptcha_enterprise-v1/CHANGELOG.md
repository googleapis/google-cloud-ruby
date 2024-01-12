# Release History

### 0.17.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.17.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23784](https://github.com/googleapis/google-cloud-ruby/issues/23784)) 

### 0.16.0 (2024-01-09)

#### Features

* Added account_id parameter to annotate_assessment 
* Added Apple developer ID and non-Google app store flag to mobile key settings 
* Added behavioral trust verdict to FraudPreventionAssessment 
* Added extended verdict reasons to RiskAnalysis 
* added stable account identifier to related group membership resources, and deprecated hashed identifier field ([#23640](https://github.com/googleapis/google-cloud-ruby/issues/23640)) 
* Added user_info field to Event 
* Additional information about events being assessed, including request UI, headers, and flags for express requests, WAF token assessments, and policy evaluations 
* Support firewall policy assessments 
* Support FirewallPolicy management calls ([#23424](https://github.com/googleapis/google-cloud-ruby/issues/23424)) 
* Support fraud signals in assessments 

### 0.15.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22922](https://github.com/googleapis/google-cloud-ruby/issues/22922)) 

### 0.14.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.14.0 (2023-06-01)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21677](https://github.com/googleapis/google-cloud-ruby/issues/21677)) 

### 0.13.0 (2023-03-23)

#### Features

* Add support for reCAPTCHA Enterprise FraudPrevention API ([#20939](https://github.com/googleapis/google-cloud-ruby/issues/20939)) 
* Add support for reCAPTCHA Enterprise TransactionData 
* Add support for reCAPTCHA Enterprise TransactionEvent 

### 0.12.0 (2022-12-09)

#### Features

* Added account verification information to the Assessment resource ([#19836](https://github.com/googleapis/google-cloud-ruby/issues/19836)) 
* Added Android package or iOS bundle with which a token was generated 
* Added option to skip the billing check when migrating a key to reCAPTCHA Enterprise 

### 0.11.0 (2022-10-18)

#### Features

* add annotation reasons REFUND, REFUND_FRAUD, TRANSACTION_ACCEPTED, TRANSACTION_DECLINED and SOCIAL_SPAM 
* support PrivatePasswordLeakVerification 
* support RetrieveLegacySecretKey 

### 0.10.0 (2022-07-07)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.9.1 (2022-06-17)

#### Bug Fixes

* Fixed serialization of the Assessment.private_password_leak_verification field

### 0.9.0 (2022-05-19)

#### Features

* add support for private_password_leak_verification

### 0.8.0 (2022-05-05)

#### Features

* Added WAF settings to application keys

#### Bug Fixes

* BREAKING CHANGE: Renamed the "parent" argument to "project" in search_related_account_group_memberships to match what the service expects

### 0.7.1 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.7.0 / 2021-12-07

#### Features

* Support the CHARGEBACK_FRAUD and CHARGEBACK_DISPUTE annotation reasons

### 0.6.0 / 2021-11-08

#### Features

* Support related account groups and account defender assessments

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.5.0 / 2021-09-21

#### Features

* Support migrate_key and get_metrics calls

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

### 0.3.0 / 2021-02-03

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

### 0.2.1 / 2020-05-25

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file

### 0.2.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.1.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.1.0 / 2020-04-23

Initial release.
