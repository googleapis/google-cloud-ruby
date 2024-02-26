# Release History

### 1.6.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24875](https://github.com/googleapis/google-cloud-ruby/issues/24875)) 

### 1.5.0 (2024-01-15)

#### Features

* Support for universe_domain ([#24265](https://github.com/googleapis/google-cloud-ruby/issues/24265)) 

### 1.4.0 (2023-03-09)

#### Features

* Support REST transport ([#20768](https://github.com/googleapis/google-cloud-ruby/issues/20768)) 

### 1.3.0 (2022-07-07)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 1.2.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.2.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.2.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.2.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.1.3 / 2021-02-03

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.1.2 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.1.1 / 2020-05-26

#### Documentation

* Cover exception changes in the migration guide

### 1.1.0 / 2020-05-19

#### Features

* The endpoint, scope, and quota_project can be set via configuration

### 1.0.0 / 2020-05-07

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.8.2 / 2020-04-01

#### Documentation

* Fixed a number of broken links.

### 0.8.1 / 2020-03-26

#### Documentation

* Document Redis 5.0 options

### 0.8.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.7.1 / 2020-02-13

#### Documentation

* Update code samples

### 0.7.0 / 2020-02-10

#### Features

* add CloudRedisClient#upgrade_instance and Instance#connect_mode (ConnectMode)

### 0.6.2 / 2020-01-23

#### Documentation

* Update copyright year
* Update Status documentation

### 0.6.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.6.0 / 2019-10-29

This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.5.2 / 2019-10-15

#### Performance Improvements

* Update network configuration

### 0.5.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.5.0 / 2019-07-08

* Support overriding service host and port.

### 0.4.0 / 2019-06-11

* Add #import_instance and #export_instance
* Add Instance#persistence_iam_identity
* Add Instance::State::IMPORTING
* Update documentation to REDIS_4_0 for Instance#redis_version
* Add VERSION constant

### 0.3.0 / 2019-04-29

* Add Instance#persistence_iam_identity attribute.
* Add CloudRedisClient#failover_instance.
* Add ListInstancesResponse#unreachable.
* Add AUTHENTICATION.md guide.
* Update generated documentation for common types.
* Update generated documentation.
* Extract gRPC header values from request.

### 0.2.3 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.2.2 / 2018-09-12

* Add V1 Client.

### 0.2.1 / 2018-09-10

* Update documentation.

### 0.2.0 / 2018-08-21

* Move Credentials location:
  * Add Google::Cloud::Redis::V1beta1::Credentials
  * Remove Google::Cloud::Redis::Credentials
* Update dependencies.
* Update documentation.

### 0.1.0 / 2018-05-09

This gem contains the Google Cloud Redis service implementation for the `google-cloud` gem.
