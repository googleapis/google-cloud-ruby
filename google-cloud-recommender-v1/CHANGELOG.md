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

### 0.7.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.6.0 / 2021-01-26

#### Features

* Support for additional forms of insight and recommendation paths

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.5.3 / 2020-10-29

#### Bug Fixes

* Configure retry and timeout for insight-related calls

### 0.5.2 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.5.1 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.5.0 / 2020-07-16

#### Features

* Add methods for interacting with insights

### 0.4.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.4.2 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.4.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file

### 0.4.0 / 2020-05-21

#### Features

* The quota_project can be set via configuration

### 0.3.3 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.3.2 / 2020-04-13

#### Documentation

* Various documentation and other updates.
  * Expanded the readme to include quickstart and logging information.
  * Added documentation for package and service modules.
  * Fixed and expanded documentation for the two method calling conventions.
  * Fixed some circular require warnings.

### 0.3.1 / 2020-04-01

#### Documentation

* Update documentation for core proto types.

### 0.3.0 / 2020-03-25

#### Features

* Path helpers can be called as module functions

#### Documentation

* Expansion and cleanup of service description text

### 0.2.0 / 2020-03-18

* Support separate project setting for quota/billing
* Include the correct default timeout and retry settings
* Eliminate some Ruby 2.7 keyword argument warnings
* Add Configuration docs and update enum return types
* Fix various formatting issues in inline documentation

### 0.1.1 / 2020-02-24

#### Documentation

* Update homepage in README and gemspec

### 0.1.0 / 2020-02-09

* Initial release
