# Release History

### 0.5.0 / 2020-06-15

#### ⚠ BREAKING CHANGES

* **container_analysis:** Convert google-cloud-container_analysis to a wrapper
* **container_analysis:** Update network configuration for IAM methods

#### Features

* Convert google-cloud-container_analysis to a wrapper
* Support separate project setting for quota/billing

#### Bug Fixes

* Restore note_path and occurrence_path resource path helpers
  * Update network configuration

#### Performance Improvements

* Update network configuration for IAM methods

#### Documentation

* Remove a broken troubleshooting link in the auth guide.
* Update copyright year

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
