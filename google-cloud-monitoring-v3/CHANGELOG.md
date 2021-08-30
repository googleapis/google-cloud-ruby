# Release History

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
