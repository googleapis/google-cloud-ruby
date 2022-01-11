# Release History

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

### 1.1.3 / 2021-02-02

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.1.2 / 2021-01-18

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.1.1 / 2020-05-27

#### Documentation

* Cover exception changes in the migration guide

### 1.1.0 / 2020-05-20

#### Features

* The endpoint, scope, and quota_project can be set via configuration

### 1.0.1 / 2020-05-18

#### Documentation

* Fix a typo in the migration guide

### 1.0.0 / 2020-05-07

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.
* More consistent spelling of module names.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.7.0 / 2020-04-08

#### Features

* Move data type classes from Oslogin to OsLogin.
  * Note: Oslogin was left as an alias, so older code should still work.

### 0.6.1 / 2020-04-01

#### Documentation

* Remove broken troubleshooting link from auth guide.

### 0.6.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.5.3 / 2020-01-23

#### Documentation

* Update copyright year

### 0.5.2 / 2020-01-09

#### Documentation

* Update product documentation

### 0.5.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.5.0 / 2019-10-29

This release requires Ruby 2.4 or later.

#### ⚠ BREAKING CHANGES

* Remove LoginProfile#suspended attribute added in version 0.4.0
* Rename OsLoginServiceClient.fingerprint_path to OsLoginServiceClient.posix_account_path
* Rename OsLoginServiceClient.project_path to OsLoginServiceClient.ssh_public_key_path
* The "ssh_public_key" argument to OsLoginServiceClient#import_ssh_public_key changed from positional to an optional keyword argument

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.4.0 / 2019-10-15

#### Features

* Add project_id and system_id arguments to OsLoginServiceClient#get_login_profile
* Add Common::PosixAccount#operating_system_type (Common::OperatingSystemType)
* Add Common::PosixAccount#name

#### Documentation and cleanup

* Update access scopes list
* Update documentation
* Update product name to include Cloud

### 0.3.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.3.0 / 2019-07-08

* Support overriding service host and port.

### 0.2.5 / 2019-06-11

* Add VERSION constant

### 0.2.4 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update documentation for common types.
* Update generated code examples.
* Extract gRPC header values from request.

### 0.2.3 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.2.2 / 2018-09-10

* Update documentation.

### 0.2.1 / 2018-08-21

* Update documentation.

### 0.2.0 / 2018-08-13

* Support v1 of the API.

### 0.1.0 / 2017-12-26

* Initial release
