# Release History

### 1.3.0 (2024-01-15)

#### Features

* Support for universe_domain ([#24257](https://github.com/googleapis/google-cloud-ruby/issues/24257)) 

### 1.2.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 1.1.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.1.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.1.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.1.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.0.3 / 2021-02-02

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.0.2 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.0.1 / 2020-06-18

#### Documentation

* Added an Enable API link to the README

### 1.0.0 / 2020-06-15

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.5.0 / 2020-01-14

#### ⚠ BREAKING CHANGES

* **container_analysis:** Remove note_path and occurrence_path resource path helpers

#### Performance Improvements

* Update network configuration for IAM methods

### 0.4.2 / 2019-11-19

#### Documentation

* Update IAM Policy documentation

### 0.4.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.4.0 / 2019-10-29

This release require Ruby 2.4 or later.

#### Features

* Use new grafeas gem instead of grafeas-client.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.3.2 / 2019-10-07

#### Features

* Update grafeas-client dependency to 0.3.

#### Documentation

* Fix role string in IAM Policy JSON example
* Update IAM Policy class description and sample code

### 0.3.1 / 2019-09-04

#### Documentation

* Update IAM documentation
  * Update GetPolicyOption#requested_policy_version docs
  * Un-deprecate Policy#version

### 0.3.0 / 2019-08-23

#### Features

* Add occurrence_path helper

#### Documentation

* Update documentation

### 0.2.0 / 2019-07-08

* Support obtaining grafeas client from the container_analysis client
* Support overriding service host and port

### 0.1.0 / 2019-06-21

* Initial release
