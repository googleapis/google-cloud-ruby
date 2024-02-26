# Release History

### 0.16.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24873](https://github.com/googleapis/google-cloud-ruby/issues/24873)) 

### 0.15.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.15.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.15.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23782](https://github.com/googleapis/google-cloud-ruby/issues/23782)) 

### 0.14.0 (2023-12-13)

#### Features

* Added support for severity in AlertPolicy ([#23647](https://github.com/googleapis/google-cloud-ruby/issues/23647)) 

### 0.13.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22921](https://github.com/googleapis/google-cloud-ruby/issues/22921)) 
#### Documentation

* Minor updates to reference documentation ([#23297](https://github.com/googleapis/google-cloud-ruby/issues/23297)) 

### 0.12.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.12.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21676](https://github.com/googleapis/google-cloud-ruby/issues/21676)) 

### 0.11.0 (2023-05-04)

#### Features

* Support adding ICMP pings to HttpCheck and TcpCheck 
* Support checker type and user labels in UptimeCheckConfig 
* Support filtering in list_uptime_check_configs 
* Support for JSON_PATH content matchers 
* Support for providing the passing http response codes in HttpCheck 
* Support Oregon, Iowa, and Virginia regional checks 
* Support user provided content-type headers in HttpCheck 

### 0.10.0 (2023-01-11)

#### Features

* Added support for the snooze API ([#19976](https://github.com/googleapis/google-cloud-ruby/issues/19976)) 

### 0.9.0 (2022-08-09)

#### Features

* Added support for evaluating missing data in AlertPolicy ([#18990](https://github.com/googleapis/google-cloud-ruby/issues/18990)) 

### 0.8.0 (2022-07-05)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.7.1 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.7.0 / 2021-12-07

#### Features

* Support for auto-closing incidents

### 0.6.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.6.0 / 2021-10-18

#### Features

* Support create_service_time_series RPC

#### Documentation

* Fix several broken links

### 0.5.0 / 2021-08-30

#### Features

* Support for controlling how notification channels are notified when an alert fires
* Support for log match conditions
* Support for user label annotations on a service
* Removed obsolete service tier field
* Updated RPC retry and timeout settings

### 0.4.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.4.2 / 2021-07-12

#### Bug Fixes

* Add project_path helper

### 0.4.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.4.0 / 2021-04-05

#### Features

* Support for querying time series using the Monitoring Query Language

### 0.3.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.2.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.1.5 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.4 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.3 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.1.2 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.1.1 / 2020-06-08

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

#### Documentation

* Fixed broken links in the reference documentation

### 0.1.0 / 2020-05-25

Initial release
