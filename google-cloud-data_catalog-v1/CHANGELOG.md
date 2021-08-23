# Release History

### 0.8.2 / 2021-08-23

#### Documentation

* Fix links to the search syntax reference

### 0.8.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.8.0 / 2021-07-29

#### Features

* Support for the replace_taxonomy call

### 0.7.3 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.7.2 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.7.1 / 2021-04-27

#### Documentation

* Fix formatting in PolicyTagManager documentation

### 0.7.0 / 2021-03-31

#### Features

* Support PolicyTagManager client

### 0.6.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.5.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.4.6 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.4.5 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.4.4 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.4.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.4.2 / 2020-06-08

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

#### Documentation

* Fixed broken links in the reference documentation

### 0.4.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file

### 0.4.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.3.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.3.0 / 2020-04-20

#### Features

* Support Scope#restricted_locations and SearchCatalogResponse#unreachable

#### Documentation

* Document asia-northeast3 region

### 0.2.0 / 2020-04-13

#### Features

* Support additional path helpers, IAM features, and other updates.
  * Added location_path helper for the DataCatalog service.
  * Added support for IAM policy options.
  * Added support for IAM policy binding conditions.
  * Added support for IAM audit config deltas.
  * Expanded the readme to include quickstart and logging information.
  * Added documentation for package and service modules.
  * Fixed and expanded documentation for the two method calling conventions.
  * Fixed some circular require warnings.

### 0.1.0 / 2020-04-06

* Initial release
