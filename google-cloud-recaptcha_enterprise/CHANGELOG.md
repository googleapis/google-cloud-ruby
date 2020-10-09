# Release History

### 1.2.0 / 2020-10-09

#### Features

* Add Key CRUD calls and new Event fields
* Add service_address and service_port to client constructor
* Move data type classes from Recaptchaenterprise to RecaptchaEnterprise.
  * Note: Recaptchaenterprise was left as an alias, so older code should still work.
* Support separate project setting for quota/billing
* Update Ruby dependency to minimum of 2.4 ([#4206](https://www.github.com/googleapis/google-cloud-ruby/issues/4206))

#### Bug Fixes

* Update minimum runtime dependencies

#### Documentation

* Remove broken troubleshooting link from auth guide.
* edit synths to fix broken links ([#5190](https://www.github.com/googleapis/google-cloud-ruby/issues/5190))
* Clarify which Google Cloud Platform products support auto-discovered credentials
* Update copyright year
* Update product home page link
* fix bad links ([#3783](https://www.github.com/googleapis/google-cloud-ruby/issues/3783))
* update links to point to new docsite ([#3684](https://www.github.com/googleapis/google-cloud-ruby/issues/3684))

### 1.1.1 / 2020-05-26

#### Documentation

* Cover exception changes in the migration guide

### 1.1.0 / 2020-05-20

#### Features

* The endpoint, scope, and quota_project can be set via configuration

### 1.0.0 / 2020-05-07

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Support for V1 of the service.
* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.
* More consistent spelling of module names.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.6.0 / 2020-04-08

#### Features

* Move data type classes from Recaptchaenterprise to RecaptchaEnterprise.
  * Note: Recaptchaenterprise was left as an alias, so older code should still work.

### 0.5.1 / 2020-04-01

#### Documentation

* Fixed a number of broken links.

### 0.5.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.4.1 / 2020-01-23

#### Documentation

* Update copyright year

### 0.4.0 / 2019-12-18

#### Features

* Add Key CRUD calls and new Event fields

### 0.3.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.3.0 / 2019-10-29

This release require Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.2.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.2.0 / 2019-07-08

* Support overriding service host and port.

### 0.1.1 / 2019-06-11

* Add VERSION constant

### 0.1.0 / 2019-04-25

* Initial release
