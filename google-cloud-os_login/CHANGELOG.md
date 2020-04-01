# Release History

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
