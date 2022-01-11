# Release History

### 2.2.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 2.2.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 2.2.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 2.2.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 2.1.3 / 2021-02-03

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 2.1.2 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 2.1.1 / 2020-05-25

#### Documentation

* Cover exception changes in the migration guide

### 2.1.0 / 2020-05-20

#### Features

* The endpoint, scope, and quota_project can be set via configuration

### 2.0.0 / 2020-05-18

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 1.5.1 / 2020-04-01

#### Documentation

* Remove broken troubleshooting link from auth guide.

### 1.5.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 1.4.0 / 2020-02-24

#### Features

* Add Queue#stackdriver_logging_config (StackdriverLoggingConfig)

### 1.3.5 / 2020-02-06

#### Performance Improvements

* Update retry configuration for IAM calls

### 1.3.4 / 2020-01-23

#### Documentation

* Update copyright year
* Update Status documentation

### 1.3.3 / 2020-01-15

#### Bug Fixes

* Restore previous network configuration timeouts changed in 1.3.2

#### Performance Improvements

* Update network configuration

#### Documentation

* Update documentation, samples, and links

### 1.3.2 / 2019-12-19

#### Performance Improvements

* Update network configuration

#### Documentation

* Update documentation, samples, and links

### 1.3.1 / 2019-11-19

#### Documentation

* Update IAM Policy documentation

### 1.3.0 / 2019-11-06

#### Features

* Add Task#http_request (HttpRequest)

#### Bug Fixes

* Update minimum runtime dependencies

### 1.2.0 / 2019-10-29

This release require Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 1.1.3 / 2019-10-01

#### Documentation

* Fix roles string in IAM Policy JSON example
* Update IAM Policy class description and sample code

### 1.1.2 / 2019-09-04

#### Documentation

* Update IAM documentation
  * Update GetPolicyOption#requested_policy_version docs
  * Un-deprecate Policy#version

### 1.1.1 / 2019-08-22

#### Documentation

* Update documentation

### 1.1.0 / 2019-07-08

* Add IAM GetPolicyOptions.
* Support overriding service host and port.

### 1.0.1 / 2019-06-11

* Add VERSION constant

### 1.0.0 / 2019-05-24

* GA release
* Remove Queue#log_sampling_ratio (Breaking change)
* Add Queue#stackdriver_logging_config
* Add StackdriverLoggingConfig
* Update IAM:
  * Deprecate Policy#version
  * Add Binding#condition
  * Add Google::Type::Expr

### 0.7.1 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update documentation for common types.

### 0.7.0 / 2019-04-15

* Add Queue#log_sampling_ratio
* Add HttpRequest#authorization_header
* Add HttpRequest#oauth_token
* Add HttpRequest#oidc_token
* Add OAuthToken
* Add OidcToken
* Update generated documentation

### 0.6.0 / 2019-03-28

* Add v2 api version

### 0.5.0 / 2019-03-20

* Alias the following CloudTasksClient class methods to instance methods.
  * location_path
  * project_path
  * queue_path
  * task_path

### 0.4.0 / 2019-03-12

* Add HTTP Request to V2beta3
  * Add Task#http_request
  * Add HttpMethod
* Update documentation

### 0.3.0 / 2019-02-01

* Add Task#dispatch_deadline attribute.
* Add HttpMethod::PATCH and HttpMethod::OPTIONS enumerated values.
* Update documentation.

### 0.2.6 / 2018-11-15

* Update network configuration.

### 0.2.5 / 2018-10-18

* Release v2beta3.

### 0.2.4 / 2018-09-20

* Update documentation.
* Change documentation URL to googleapis GitHub org.

### 0.2.3 / 2018-09-10

* Update documentation.

### 0.2.2 / 2018-08-21

* Update documentation.

### 0.2.1 / 2018-07-05

* Update google-gax dependency to version 1.3.

### 0.2.0 / 2018-06-28

* Add constructor arguments.
* Update documentation.

### 0.1.0 / 2018-05-29

* Initial release
