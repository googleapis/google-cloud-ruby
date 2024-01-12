# Release History

### 0.17.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.17.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23784](https://github.com/googleapis/google-cloud-ruby/issues/23784)) 

### 0.16.0 (2023-12-13)

#### Features

* Support cost_in_local_currency field in the cost projection ([#23648](https://github.com/googleapis/google-cloud-ruby/issues/23648)) 

### 0.15.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22923](https://github.com/googleapis/google-cloud-ruby/issues/22923)) 

### 0.14.0 (2023-09-07)

#### Features

* Add mark_recommendation_dismissed() method ([#22877](https://github.com/googleapis/google-cloud-ruby/issues/22877)) 

### 0.13.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.13.0 (2023-06-01)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21677](https://github.com/googleapis/google-cloud-ruby/issues/21677)) 

### 0.12.0 (2023-03-08)

#### Features

* Support REST transport ([#20628](https://github.com/googleapis/google-cloud-ruby/issues/20628)) 

### 0.11.0 (2022-07-07)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.10.0 (2022-06-28)

#### Features

* add support for insight type config 
* support getting and updating recommender config 

### 0.9.0 (2022-04-15)

#### Features

* add recommendation priority and insights severity projection

### 0.8.6 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.8.5 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.8.4 / 2021-11-02

#### Documentation

* Formatting fixes for reference documentation

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
