# Release History

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
