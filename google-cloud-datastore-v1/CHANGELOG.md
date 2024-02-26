# Release History

### 0.17.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24869](https://github.com/googleapis/google-cloud-ruby/issues/24869)) 

### 0.16.3 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.16.2 (2024-01-25)

#### Bug Fixes

* BREAKING CHANGE: Removed unsupported query mode argument 
* BREAKING CHANGE: Removed unsupported query stats field from query responses 

### 0.16.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.16.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23778](https://github.com/googleapis/google-cloud-ruby/issues/23778)) 

### 0.15.0 (2024-01-09)

#### Features

* Support query modes for run_query and run_aggregation_query RPCs 
* Support stats returned from run_query and run_aggregation_query RPCs 

### 0.14.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22919](https://github.com/googleapis/google-cloud-ruby/issues/22919)) 

### 0.13.1 (2023-09-04)

#### Documentation

* Clarify description of PropertyReference#name ([#22798](https://github.com/googleapis/google-cloud-ruby/issues/22798)) 

### 0.13.0 (2023-08-04)

#### Features

* Support SUM/AVG aggregations in Datastore ([#22679](https://github.com/googleapis/google-cloud-ruby/issues/22679)) 

### 0.12.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21674](https://github.com/googleapis/google-cloud-ruby/issues/21674)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.11.1 (2023-03-24)

#### Documentation

* Improved  query API documentation ([#21005](https://github.com/googleapis/google-cloud-ruby/issues/21005)) 

### 0.11.0 (2023-03-08)

#### Features

* Support REST transport ([#20625](https://github.com/googleapis/google-cloud-ruby/issues/20625)) 

### 0.10.0 (2023-02-16)

#### Features

* Added creation time to EntityResult and MutationResult 
* Added support for OR queries ([#20432](https://github.com/googleapis/google-cloud-ruby/issues/20432)) 

### 0.9.0 (2023-01-19)

#### Features

* Return IDs of transactions started as part of requests 
* Support options for beginning new transactions on read and commit requests ([#20026](https://github.com/googleapis/google-cloud-ruby/issues/20026)) 

### 0.8.0 (2023-01-15)

#### Features

* Set database ID routing header ([#20010](https://github.com/googleapis/google-cloud-ruby/issues/20010)) 

### 0.7.0 (2022-10-03)

#### Features

* Support for run_aggregation_query call ([#19239](https://github.com/googleapis/google-cloud-ruby/issues/19239)) 

### 0.6.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.5.0 (2022-04-19)

#### Features

* Support for read, commit, and update timestamps (private preview only)

### 0.4.0 / 2022-03-30

#### Features

* Support for IN, NOT_IN, and NOT_EQUAL operators

### 0.3.5 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.3.4 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.3.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.3.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.3.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.3.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.2.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.1.3 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.2 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.1 / 2020-08-06

#### Bug Fixes

* Fix retries by converting error names to integer codes

### 0.1.0 / 2020-07-27

Initial release.
