# Release History

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
