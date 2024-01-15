# Release History

### 1.6.0 (2024-01-15)

#### Features

* Support for universe_domain ([#24254](https://github.com/googleapis/google-cloud-ruby/issues/24254)) 

### 1.5.0 (2023-03-09)

#### Features

* Support REST transport ([#20765](https://github.com/googleapis/google-cloud-ruby/issues/20765)) 

### 1.4.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 1.3.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.3.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.3.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.3.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.2.0 / 2021-02-23

#### Features

* Remove obsolete v1beta1 client from dependencies

### 1.1.4 / 2021-02-02

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.1.3 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.1.2 / 2020-06-18

#### Documentation

* Updated the product URL in the readme

### 1.1.1 / 2020-05-26

#### Documentation

* Cover exception changes in the migration guide

### 1.1.0 / 2020-05-20

#### Features

* The endpoint, scope, and quota_project can be set via configuration

### 1.0.2 / 2020-05-05

#### Bug Fixes

* Eliminated a circular require warning.

#### Documentation

* Updated the sample timeouts in the migration guide to reflect seconds

### 1.0.1 / 2020-04-24

#### Documentation

* Cover multi-pattern path helpers in the migration guide

### 1.0.0 / 2020-04-16

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Easier access to path helper methods.

See the MIGRATING file in the documentation for more detailed information and instructions for migrating from earlier versions.

### 0.8.1 / 2020-03-16

#### Documentation

* Several corrections to brace escaping in documentation

### 0.8.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

#### Documentation

* Update enum return type to full module namespace

### 0.7.0 / 2020-02-04

#### Features

* Add GcsDestination#uri_prefix

### 0.6.1 / 2020-01-22

#### Documentation

* Update copyright year
* Update Status documentation

### 0.6.0 / 2019-12-18

#### Features

* Support real-time feeds in asset V1

### 0.5.2 / 2019-11-19

#### Documentation

* Update IAM Policy documentation

### 0.5.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.5.0 / 2019-10-29

* This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.4.0 / 2019-10-15

#### Features

* Add OutputConfig#bigquery_destination
* Add ContentType::ORG_POLICY and ContentType::ACCESS_POLICY constants

#### Documentation

* Document some fields as required.
* Update some documented URLs.

### 0.3.3 / 2019-10-03

#### Documentation

* Update IAM Policy documentation

### 0.3.2 / 2019-09-04

#### Documentation

* Update IAM documentation
  * Update GetPolicyOption#requested_policy_version docs
  * Un-deprecate Policy#version

### 0.3.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.3.0 / 2019-07-08

* Support overriding service host and port for generated clients
* Updates to IAM

### 0.2.1 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update documentation for common types.
* Extract gRPC header values from request.

### 0.2.0 / 2019-03-21

* Add v1 api version
* Alias AssetServiceClient::project_path to instance method
* Update documentation

### 0.1.2 / 2019-02-01

* Update documentation.

### 0.1.1 / 2018-11-19

* Update rubygems homepage link

### 0.1.0 / 2018-08-21

* Initial release.
