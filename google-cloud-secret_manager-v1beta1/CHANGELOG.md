# Release History

### 0.8.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.8.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.8.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.8.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.7.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.6.6 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.6.5 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.6.4 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.6.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.6.2 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.6.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file

### 0.6.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.5.2 / 2020-05-07

#### Documentation

* Annotate several additional fields/arguments as required.

### 0.5.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.5.0 / 2020-04-13

#### Features

* Support additional IAM features, and other updates.
  * Added support for IAM policy options.
  * Added support for IAM policy binding conditions.
  * Added support for IAM audit config deltas.
  * Expanded the readme to include quickstart and logging information.
  * Added documentation for package and service modules.
  * Fixed and expanded documentation for the two method calling conventions.
  * Fixed some circular require warnings.

### 0.4.1 / 2020-04-01

#### Documentation

* Update documentation for core proto types.

### 0.4.0 / 2020-03-25

#### Features

* Path helpers can be called as module functions

#### Documentation

* Expansion and cleanup of service description text

### 0.3.0 / 2020-03-18

* Support separate project setting for quota/billing
* Include the correct default timeout and retry settings
* Eliminate some Ruby 2.7 keyword argument warnings
* Fix some formatting issues in the inline documentation

### 0.2.3 / 2020-03-04

#### Documentation

* Add Configuration docs and update enum return types

### 0.2.2 / 2020-02-24

#### Documentation

* Update homepage in README and gemspec

### 0.2.1 / 2020-02-06

#### Documentation

* Fix type declarations for repeated fields
* Update docs for common FieldMask and Timestamp types

### 0.2.0 / 2020-01-17

#### Features

* Provide resource path helpers

### 0.1.0 / 2020-01-09

* Initial release.
