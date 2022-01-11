# Release History

### 0.11.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.11.2 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.11.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.11.0 / 2021-07-29

#### Features

* Support filters when listing secrets and secret versions

### 0.10.2 / 2021-07-12

#### Bug Fixes

* Minor updates to retry policy for access_secret_version

#### Documentation

* Clarify some language around authentication configuration

### 0.10.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.10.0 / 2021-05-21

#### Features

* Support for optimistic concurrency control using Etags

### 0.9.0 / 2021-04-05

#### Features

* Support for rotation schedules

### 0.8.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0
* Support publishing to PubSub when control plane operations occur on a secret

### 0.7.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.6.0 / 2021-01-26

#### Features

* added expire_time and ttl fields to Secret

### 0.5.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.5.0 / 2020-09-10

#### Features

* Support for replication status and customer-managed encryption

### 0.4.5 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.4.4 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.4.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.4.2 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.4.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file

### 0.4.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.3.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.3.0 / 2020-04-13

#### Features

* Support additional IAM features, and other updates.
  * Added support for IAM policy options.
  * Added support for IAM policy binding conditions.
  * Added support for IAM audit config deltas.
  * Expanded the readme to include quickstart and logging information.
  * Added documentation for package and service modules.
  * Fixed and expanded documentation for the two method calling conventions.
  * Fixed some circular require warnings.

### 0.2.1 / 2020-04-06

#### Documentation

* Update docs for core protobuf types.

### 0.2.0 / 2020-03-25

#### Features

* Path helpers can be called as module functions

#### Documentation

* Expansion and cleanup of service description text

### 0.1.0 / 2020-03-16

Initial release.
