# Release History

### 0.5.5 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.5.4 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.5.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.5.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.5.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.4.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible, and support the wait_operation RPC for long-running operations

### 0.3.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.3.0 / 2020-12-02

#### Features

* Support text detection parameters

### 0.2.5 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credential values

### 0.2.4 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.2.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.2.2 / 2020-06-05

#### Bug Fixes

* Fix a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.2.1 / 2020-05-22

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file

### 0.2.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.1.5 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.1.4 / 2020-04-22

#### Bug Fixes

* Operations client honors its main client's custom endpoint.

### 0.1.3 / 2020-04-13

#### Documentation

* Various documentation and other updates.
  * Expanded the readme to include quickstart and logging information.
  * Added documentation for package and service modules.
  * Fixed and expanded documentation for the two method calling conventions.
  * Fixed some circular require warnings.

### 0.1.2 / 2020-04-06

#### Documentation

* Fix a broken product documentation link.

### 0.1.1 / 2020-04-01

#### Documentation

* Update documentation for core proto types.

### 0.1.0 / 2020-03-25

Initial release.
