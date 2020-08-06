# Release History

### 0.3.4 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.3.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.3.2 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.3.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file
* The long-running operations client honors the quota_project config

### 0.3.0 / 2020-05-21

#### Features

* The quota_project can be set via configuration

### 0.2.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.2.0 / 2020-04-22

#### Features

* Support for speech adaptation configuration.

#### Bug Fixes

* Operations client honors its main client's custom endpoint.

### 0.1.2 / 2020-04-13

#### Documentation

* Various documentation and other updates.
  * Expanded the readme to include quickstart and logging information.
  * Added documentation for package and service modules.
  * Fixed and expanded documentation for the two method calling conventions.
  * Fixed some circular require warnings.

### 0.1.1 / 2020-04-01

#### Documentation

* Update documentation for core proto types.

### 0.1.0 / 2020-03-25

Initial release.
