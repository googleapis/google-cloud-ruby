# Release History

### 0.11.0 (2022-07-07)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.10.0 (2022-05-19)

#### Features

* add BigQuery configuration and state for Subscriptions

### 0.9.0 (2022-04-20)

#### Features

* Support for update masks when setting IAM policies

### 0.8.0 / 2022-04-01

#### Features

* increase GRPC max metadata size to 4 MB

### 0.7.1 / 2022-02-15

#### Bug Fixes

* Fix misspelled field name StreamingPullResponse#acknowledge_confirmation (was acknowlege_confirmation)

### 0.7.0 / 2022-02-08

#### Features

* Support acknowledgment confirmations when exactly-once delivery is enabled
* Support exactly-once delivery when creating a subscription

### 0.6.2 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.6.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.6.0 / 2021-08-11

#### Features

* Support setting message retention duration on a topic

#### Bug Fixes

* Honor client-level timeout configuration

### 0.5.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.5.1 / 2021-07-08

#### Bug Fixes

* Removed a proto file that is duplicated from the iam-v1 gem

### 0.5.0 / 2021-07-07

#### Features

* Add subscription properties to streaming pull response

### 0.4.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.4.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

#### Documentation

* Remove experimental note for schema APIs

### 0.3.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.2.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.0 / 2021-01-05

#### Features

* add schema service ([#8413](https://www.github.com/googleapis/google-cloud-ruby/issues/8413))

### 0.1.2 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.1 / 2020-08-05

#### Bug Fixes

* Fix retries by converting error names to integer codes

#### Documentation

* Remove experimental warning for ordering keys properties

### 0.1.0 / 2020-07-27

Initial release.
