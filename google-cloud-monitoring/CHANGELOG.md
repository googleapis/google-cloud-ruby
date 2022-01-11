# Release History

### 1.3.1 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.3.0 / 2021-09-28

#### Features

* Added support for the MetricsScope service

### 1.2.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.2.1 / 2021-07-01

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.2.0 / 2021-04-06

#### Features

* Support for querying time series using the Monitoring Query Language

### 1.1.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.0.2 / 2021-02-02

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.0.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.0.0 / 2020-06-01

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.38.0 / 2020-04-21

#### Features

* Support custom request method and body in uptime http checks.

#### Documentation

* Clarify TimeInterval resolution.

### 0.37.2 / 2020-04-06

#### Documentation

* Fix some broken links to the monitoring docs on cloud.google.com

### 0.37.1 / 2020-04-01

#### Documentation

* Document ServiceTier as obsolete and unused.
* Remove broken troubleshooting link from auth guide.

### 0.37.0 / 2020-03-25

#### Features

* Add TimeSeriesQueryLanguageCondition and MeshIstio
  * Add Condition#condition_time_series_query_language (TimeSeriesQueryLanguageCondition)
  * Add Service::MeshIstio

### 0.36.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.35.1 / 2020-02-18

#### Documentation

* Update product links and reformat docs

### 0.35.0 / 2020-02-04

#### Features

* Add NotificationChannelDescriptor#launch_stage
  * Update documentation formatting

### 0.34.2 / 2020-01-23

#### Documentation

* Update copyright year
* Update Status documentation

### 0.34.1 / 2019-12-20

#### Documentation

* Update description of MetricDescriptor#unit in lower-level API

### 0.34.0 / 2019-12-18

#### Features

* Add support for the Dashboards API.
* Add support for the ServiceMonitoring API.

### 0.33.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.33.0 / 2019-10-29

This release require Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.32.0 / 2019-10-03

#### Features

* Additions to the content matcher for uptime check
  * Add recursive argument to GroupServiceClient#delete_group method.
  * Add AlertPolicy#validity
  * Remove UptimeCheckConfig#is_internal (BREAKING CHANGE)
  * Add UptimeCheckConfig::HttpCheck#validate_ssl
  * Add InternalChecker::State module and constants:
      * Add InternalChecker::State::CREATING
      * Add InternalChecker::State::RUNNING
  * Add ContentMatcher::ContentMatcherOption module and constants:
      * Add ContentMatcher::ContentMatcherOption::CONTAINS_STRING
      * Add ContentMatcher::ContentMatcherOption::NOT_CONTAINS_STRING
      * Add ContentMatcher::ContentMatcherOption::MATCHES_REGEX
      * Add ContentMatcher::ContentMatcherOption::NOT_MATCHES_REGEX
  * Add UptimeCheckConfig::ContentMatcher:: ContentMatcherOption module and constants:
      * Add UptimeCheckConfig::ContentMatcher:: ContentMatcherOption::CONTAINS_STRING
      * Add UptimeCheckConfig::ContentMatcher:: ContentMatcherOption::NOT_CONTAINS_STRING
      * Add UptimeCheckConfig::ContentMatcher:: ContentMatcherOption::MATCHES_REGEX
      * Add UptimeCheckConfig::ContentMatcher:: ContentMatcherOption::NOT_MATCHES_REGEX
  * Update documentation

### 0.31.0 / 2019-08-23

#### Features

* Add NotificationChannel verification
  * Add NotificationChannelServiceClient#send_notification_channel_verification_code
  * Add NotificationChannelServiceClient#get_notification_channel_verification_code
  * Add NotificationChannelServiceClient#verify_notification_channel

#### Documentation

* Update documentation

### 0.30.0 / 2019-07-08

* Support overriding service host and port.

### 0.29.5 / 2019-06-11

* Add documentation for MetricDescriptor#launch_stage and
  MonitoredResourceDescriptor#launch_stage
* Deprecate MetricDescriptor:: MetricDescriptorMetadata#launch_stage
* Add VERSION constant

### 0.29.4 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update generated documentation.
* Update generated code examples.
* Extract gRPC header values from request.

### 0.29.3 / 2019-02-01

* Update network configuration.
* Update documentation.

### 0.29.2 / 2018-09-20

* Update Monitoring generated files.
  * Add MetricDescriptorMetadata.
* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.29.1 / 2018-09-10

* Update documentation.

### 0.29.0 / 2018-08-21

* Move Credentials location:
  * Add Google::Cloud::Monitoring::V3::Credentials
  * Remove Google::Cloud::Monitoring::Credentials
* Update documentation.

### 0.28.0 / 2018-04-19

* Refresh generated client and documentation for updated V3 Monitoring API.

### 0.27.0 / 2017-12-19

* Update google-gax dependency to 1.0.

### 0.26.1 / 2017-11-15

* Fix Credentials environment variable names.

### 0.26.0 / 2017-11-14

* Update generated GAPIC code and documentation.
* Updated `google-gax` (`grpc`, `google-protobuf`), `googleauth` dependencies.

### 0.25.0 / 2017-07-11

* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.
* Update README.
* Update gem spec homepage links.

### 0.24.0 / 2017-03-31

* Updated documentation
* Automatic retry on `UNAVAILABLE` errors

### 0.23.2 / 2017-03-03

* Update GRPC header value sent to the Monitoring API.

### 0.23.1 / 2017-03-01

* Update GRPC header value sent to the Monitoring API.

### 0.23.0 / 2017-02-21

* Fix GRPC retry bug
* The client_config data structure has replaced retry_codes/retry_codes_def with retry_codes
* Update GRPC/Protobuf/GAX dependencies

### 0.22.0 / 2017-01-27

* Change class names in low-level API (GAPIC)
* Add LICENSE to package

### 0.21.0 / 2016-10-20

* First release
