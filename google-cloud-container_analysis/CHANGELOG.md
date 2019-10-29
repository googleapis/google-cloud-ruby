# Release History

### 0.4.0 / 2019-10-29

#### Features

* Rename grafeas gem
  * Rename grafeas gem from grafeas-client
  * Create new grafeas-client gem that depends on grafeas
  * Update google-cloud-container_analysis to use grafeas
* Update Ruby dependency to minimum of 2.4 ([#4206](https://www.github.com/googleapis/google-cloud-ruby/issues/4206))

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
