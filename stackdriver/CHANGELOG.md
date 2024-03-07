# Release History

### 0.22.0 (2024-03-07)

#### Features

* Update minimum supported Ruby version to 2.7 ([#25298](https://github.com/googleapis/google-cloud-ruby/issues/25298)) 

### 0.21.1 / 2021-05-18

#### Documentation

* Remove Debugger description from the readmes

### 0.21.0 / 2021-03-10

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.20.1 / 2020-12-02

#### Bug Fixes

* Remove debugger references completely

### 0.20.0 / 2020-12-02

* BREAKING CHANGE: Removed google-cloud-debugger from the standard suite of stackdriver agents. If you are using the debugger, include the google-cloud-debugger gem explicitly.
* Update to version 2.x of google-cloud-logging
* Update to version 0.41 of google-cloud-error_reporting
* Update to version 0.40 of google-cloud-trace

### 0.16.1 / 2019-12-18

#### Documentation

* update use_logging description

### 0.16.0 / 2019-11-06

#### Other

* Update Ruby dependency to minimum of 2.4

### 0.15.5 / 2019-08-23

#### Documentation

* Update documentation

### 0.15.4 / 2019-06-13

* Fix Logging example in INSTRUMENTATION_CONFIGURATION.md

### 0.15.3 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.15.2 / 2018-09-12

* Add missing documentation files to package.

### 0.15.1 / 2018-09-10

* Update documentation.

### 0.15.0 / 2018-05-24

* Debugger 0.32.0
* Trace 0.33.0

### 0.14.0 / 2018-02-27

* Debugger 0.31.0
  * Use Google Cloud Shared Configuration.
  * Fix for mutation detection using Ruby 2.5.
  * Support disabling mutation detection in debugger evaluation.
* Error Reporting 0.30.0
  * Use Google Cloud Shared Configuration.
* Logging 1.5.0
  * Use Google Cloud Shared Configuration.
  * Deprecated Logging Sink attributes.
* Trace 0.31.0
  * Use Google Cloud Shared Configuration.
  * Update authentication documentation.

### 0.13.0 / 2017-12-19

* Trace 0.30.0 release.

### 0.12.0 / 2017-12-19

* Debugger 0.30.0 release.
* Error Reporting 0.29.0 release.
* Logging 1.4.0 release.
* Trace 0.29.0 release.

### 0.11.0 / 2017-11-14

* Debugger 0.29.0 release.
* Error Reporting 0.28.0 release.
* Logging 1.3.0 release.
* Trace 0.28.0 release.

### 0.10.0 / 2017-09-08

* Error Reporting 0.27.0 release.

### 0.9.0 / 2017-08-25

* Debugger 0.28.0 release.

### 0.8.0 / 2017-08-07

* Debugger 0.27.0 release.
* Trace 0.27.0 release.

### 0.7.0 / 2017-07-11

* Debugger 0.26.0 release.
* Error Reporting 0.26.0 release.
* Logging 1.2.0 release.
* Trace 0.26.0 release.

### 0.6.0 / 2017-05-25

* Debugger 0.25.0 release.
* Error Reporting 0.25.0 release.
* Logging 1.1.0 release.
* Trace 0.25.0 release.
* Remove `google-cloud-monitoring` from this umbrella gem.

### 0.5.0 / 2017-03-31

* Logging 1.0 release
* Updated dependencies on all other gems

### 0.4.1 / 2017-02-27

* Set version constraints on the gem dependencies for individual stackdriver services. Current versions are:
  * **google-cloud-logging** `~> 0.24.0`
  * **google-cloud-error_reporting** `~> 0.23.1`
  * **google-cloud-monitoring** `~> 0.23.0`
  * **google-cloud-trace** `~> 0.23.0`

### 0.4.0 / 2016-12-22

* Now provides Stackdriver Trace instrumentation by including google-cloud-trace.

### 0.3.0 / 2016-11-07

This gem is an umbrella gem that serves as the single drop-in gem for users interested in using the Stackdriver services from their Ruby applications.

The initial release of stackdriver gem includes the following Stackdriver gems to be used in Ruby applications:
* google-cloud-logging
* google-cloud-error_reporting
