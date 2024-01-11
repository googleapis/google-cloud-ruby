# Release History

### 0.12.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23781](https://github.com/googleapis/google-cloud-ruby/issues/23781)) 

### 0.11.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22921](https://github.com/googleapis/google-cloud-ruby/issues/22921)) 

### 0.10.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.10.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21676](https://github.com/googleapis/google-cloud-ruby/issues/21676)) 

### 0.9.0 (2023-05-08)

#### Features

* Added bucket_name field to LogMetric 
* Support analytics_enabled field for LogBucket 
* Support for configuring the KMS key version name 
* Support for managing links 
* Support index configuration for LogBucket 
* Support RPCs for creating and updating log buckets asynchronously 

### 0.8.1 (2022-07-28)

#### Documentation

* Fixed some cross-reference links ([#18879](https://github.com/googleapis/google-cloud-ruby/issues/18879)) 

### 0.8.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.7.0 / 2022-03-07

#### Features

* Add KMS configuration in settings ([#17682](https://www.github.com/googleapis/google-cloud-ruby/issues/17682))

### 0.7.0 / 2022-03-06

#### Features

* Add KMS configuration in settings ([#17682](https://www.github.com/googleapis/google-cloud-ruby/issues/17682))

### 0.6.0 / 2022-02-18

#### Features

* Support for get_settings and update_settings
* Support for copy_log_entries
* Support for splitting log entries and sending as a sequence of parts
* Support for restricted fields in a log bucket
* Support for CMEK settings for a log bucket
* Support for disabling metrics
* Various clarifications and formatting fixes in the reference documentation

### 0.5.6 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.5.5 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.5.4 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.5.3 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.5.2 / 2021-07-08

#### Bug Fixes

* Remove two proto files that are duplicated from the common-protos gem

### 0.5.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.4.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.3.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.3.0 / 2020-12-02

#### Features

* Support for tail_log_entries

### 0.2.0 / 2020-11-19

#### Features

* Support for managing buckets and views

### 0.1.3 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.2 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.1.1 / 2020-07-08

#### Bug Fixes

* Retry on internal errors

### 0.1.0 / 2020-07-07

Initial release.
