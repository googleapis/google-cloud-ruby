# Release History

### 0.12.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23774](https://github.com/googleapis/google-cloud-ruby/issues/23774)) 

### 0.11.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22917](https://github.com/googleapis/google-cloud-ruby/issues/22917)) 
#### Documentation

* Minor updates to reference documentation ([#23298](https://github.com/googleapis/google-cloud-ruby/issues/23298)) 

### 0.10.0 (2023-08-03)

#### Features

* Provide more enum options for Parameter type ([#22670](https://github.com/googleapis/google-cloud-ruby/issues/22670)) 
* Support Encryption configuration in Transfer Config ([#22670](https://github.com/googleapis/google-cloud-ruby/issues/22670)) 

### 0.9.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21672](https://github.com/googleapis/google-cloud-ruby/issues/21672)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.8.0 (2023-03-08)

#### Features

* Support REST transport ([#20625](https://github.com/googleapis/google-cloud-ruby/issues/20625)) 

### 0.7.1 (2023-02-28)

#### Documentation

* Clarify service account name description ([#20536](https://github.com/googleapis/google-cloud-ruby/issues/20536)) 

### 0.7.0 (2023-01-05)

#### Features

* Added support for location ([#19935](https://github.com/googleapis/google-cloud-ruby/issues/19935)) 

### 0.6.1 (2022-11-17)

#### Documentation

* Format and clean up docs 

### 0.6.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.5.1 / 2022-04-01

#### Bug Fixes

* Remove an unused require

### 0.5.0 / 2022-01-20

#### Features

* Support for allowing customer to enroll a datasource.

### 0.4.6 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.4.5 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.4.4 / 2021-08-20

#### Documentation

* Updated various proto field descriptions

### 0.4.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.4.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.4.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.4.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.3.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.2.6 / 2021-01-20

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.5 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.2.4 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.2.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.2.2 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.2.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file

### 0.2.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

#### Documentation

* Update BigQuery Data Transfer Service product name

### 0.1.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.1.0 / 2020-04-23

Initial release.
