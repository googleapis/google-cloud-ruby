# Release History

### 0.15.1 (2023-09-26)

#### Documentation

* update service documentation ([#23359](https://github.com/googleapis/google-cloud-ruby/issues/23359)) 

### 0.15.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22918](https://github.com/googleapis/google-cloud-ruby/issues/22918)) 

### 0.14.0 (2023-09-07)

#### Features

* Add project_path() method to Paths module ([#22901](https://github.com/googleapis/google-cloud-ruby/issues/22901)) 

### 0.13.2 (2023-09-04)

#### Documentation

* update some reference docs ([#22851](https://github.com/googleapis/google-cloud-ruby/issues/22851)) 
* update some reference docs ([#22851](https://github.com/googleapis/google-cloud-ruby/issues/22851)) 

### 0.13.1 (2023-08-04)

#### Documentation

* Improve documentation format ([#22684](https://github.com/googleapis/google-cloud-ruby/issues/22684)) 

### 0.13.0 (2023-06-20)

#### Features

* support project_billing_info_path 

### 0.12.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21673](https://github.com/googleapis/google-cloud-ruby/issues/21673)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.11.0 (2023-03-08)

#### Features

* Support REST transport ([#20625](https://github.com/googleapis/google-cloud-ruby/issues/20625)) 

### 0.10.0 (2022-11-16)

#### Features

* support geo_taxonomy 

### 0.9.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.8.0 (2022-04-20)

#### Features

* Support for update masks when setting IAM policies

### 0.7.5 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.7.4 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.7.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.7.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.7.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.7.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.6.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.5.6 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.5.5 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.5.4 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.5.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.5.2 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.5.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file

### 0.5.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.4.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.4.0 / 2020-04-13

#### Features

* Support additional IAM features, and other updates.
  * Added support for IAM policy options.
  * Added support for IAM policy binding conditions.
  * Added support for IAM audit config deltas.
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
