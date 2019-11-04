# Release History

### 1.2.0 / 2019-11-04

#### Features

* Update Ruby dependency to minimum of 2.4 ([#4206](https://www.github.com/googleapis/google-cloud-ruby/issues/4206))
* Deprecate CloudSchedulerClient.project_path helper method
  * Update documentation
    * Mark several fields as required
  * Update network configuration

#### Bug Fixes

* Update minimum runtime dependencies

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
