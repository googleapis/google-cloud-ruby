# Release History

### 0.8.0 (2022-07-05)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.7.0 (2022-04-14)

#### Features

* Support for dashboard filters
* Support for dashboard labels
* Support for time series table widgets
* Support for collapsible group widgets
* Support for logs panel widgets
* Support for target axis when plotting a threshold
* Support for a second Y axis when plotting data sets

### 0.6.6 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.6.5 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.6.4 / 2021-08-30

#### Documentation

* Fix the links to the corresponding main client library

### 0.6.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.6.2 / 2021-07-21

#### Documentation

* Fix a few broken links in the client class documentation

### 0.6.1 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.6.0 / 2021-07-08

#### Features

* Support for validate-only mode in create_dashboard and update_dashboard; support for alert chart widgets

### 0.5.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.5.0 / 2021-03-30

#### Features

* Added support for the mosaic layout

#### Documentation

* Fix a few broken links in the reference docs

### 0.4.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.3.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.2.4 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.3 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.2.2 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.2.1 / 2020-06-18

#### Bug Fixes

* Set the correct timeout and retry policy defaults.

### 0.2.0 / 2020-06-15

#### Features

* Add support for secondary_aggregation and Monitoring Query Language

### 0.1.1 / 2020-06-08

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

#### Documentation

* Fixed broken links in the reference documentation

### 0.1.0 / 2020-05-25

Initial release
