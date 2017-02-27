# Release History

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
