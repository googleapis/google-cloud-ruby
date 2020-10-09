# Release History

### 2.2.0 / 2020-10-09

#### Features

* Add service_address and service_port to client constructor
* Deprecate CloudSchedulerClient.project_path helper method
  * Update documentation
    * Mark several fields as required
  * Update network configuration
* Support separate project setting for quota/billing
* Update Ruby dependency to minimum of 2.4 ([#4206](https://www.github.com/googleapis/google-cloud-ruby/issues/4206))

#### Bug Fixes

* Update minimum runtime dependencies

#### Documentation

* Remove broken troubleshooting link from auth guide.
* Update copyright year
* Update documentation with slight formatting and wording changes
* Update product home page links
* Update Status documentation
* fix bad links ([#3783](https://www.github.com/googleapis/google-cloud-ruby/issues/3783))
* update links to point to new docsite ([#3684](https://www.github.com/googleapis/google-cloud-ruby/issues/3684))

### 2.1.1 / 2020-05-26

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

### 1.3.1 / 2020-04-01

#### Documentation

* Remove broken troubleshooting link from auth guide.

### 1.3.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 1.2.1 / 2020-01-23

#### Documentation

* Update copyright year
* Update Status documentation

### 1.2.0 / 2019-11-04

This release requires Ruby 2.4 or later.

#### Bug Fixes

* Deprecate CloudSchedulerClient.project_path helper method

#### Documentation

* Clarify which Google Cloud Platform environments support automatic authentication
* Clarify required status of several fields

#### Other

* Update minimum runtime dependencies
* Update some network timeouts

### 1.1.2 / 2019-10-18

#### Documentation

* Update documentation with slight formatting and wording changes

### 1.1.1 / 2019-08-23

#### Documentation

* Update documentation

### 1.1.0 / 2019-07-08

* Support overriding service host and port.

### 1.0.1 / 2019-06-11

* Add VERSION constant

### 1.0.0 / 2019-05-24

* GA release
* Add Job#attempt_deadline
  * Add HttpTarget#authorization_header
  * Add HttpTarget#oauth_token (OAuthToken)
  * Add HttpTarget#oidc_token (OidcToken)

### 0.3.1 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update documentation for common types.

### 0.3.0 / 2019-04-15

* Add Job#attempt_deadline
* Add HttpTarget#oauth_token
* Add HttpTarget#oidc_token
* Add OAuthToken
* Add OidcToken
* Extract gRPC header values from request
* Update generated documentation

### 0.2.0 / 2019-03-12

* Add v1 api version

### 0.1.0 / 2018-12-13

* Initial release
