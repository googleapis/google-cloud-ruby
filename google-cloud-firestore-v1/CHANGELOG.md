# Release History

### 0.12.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24870](https://github.com/googleapis/google-cloud-ruby/issues/24870)) 

### 0.11.1 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.11.0 (2024-01-29)

#### Features

* Added a bloom filter of unchanged document names (#21547)
* Uses binary protobuf definitions for better forward compatibility (#21675)
* Support SUM/AVG aggregations in Firestore (#22673)
* Support for universe_domain (#23779)
* Support for channel pool configuration (#22920)

#### Bug Fixes

* Set request params header using resource prefix
* Don't use self-signed JWT credentials if the global configuration endpoint has been modified

### 0.10.0 (2023-02-17)

#### Features

* Added support for REST transport ([#20444](https://github.com/googleapis/google-cloud-ruby/issues/20444)) 

### 0.9.0 (2023-02-15)

#### Features

* Added OR query support ([#20428](https://github.com/googleapis/google-cloud-ruby/issues/20428)) 

### 0.8.0 (2022-09-16)

#### Features

* Support for run_aggregation_query call ([#19140](https://github.com/googleapis/google-cloud-ruby/issues/19140)) 
* Support for the location client 

### 0.7.1 (2022-08-24)

#### Documentation

* Clarifications in the order_by field of a query ([#19056](https://github.com/googleapis/google-cloud-ruby/issues/19056)) 

### 0.7.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.6.0 (2022-06-14)

#### Features

* Support read_time arguments to the partition_query and list_collection_ids calls

### 0.5.0 (2022-04-28)

#### Features

* run_query reports whether the request is complete and no more documents will be returned

### 0.4.8 (2022-04-19)

#### Documentation

* Minor clarifications to filter documentation

### 0.4.7 / 2022-03-07

#### Bug Fixes

* remove requiring unused annotations_pb

### 0.4.6 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.4.5 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.4.4 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.4.3 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.4.2 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.4.1 / 2021-04-16

#### Bug Fixes

* Retry on RESOURCE_EXHAUSTED errors

### 0.4.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.3.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.2.3 / 2021-01-20

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.2 / 2020-10-26

#### Bug Fixes

* Retry partition_query calls on INTERNAL and DEADLINE_EXCEEDED errors

### 0.2.1 / 2020-10-14

#### Bug Fixes

* Set retry/timeout for PartitionQuery

### 0.2.0 / 2020-09-03

#### Features

* Support inequality operators in structured queries

### 0.1.2 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.1 / 2020-08-06

#### Bug Fixes

* Fix retries by converting error names to integer codes

### 0.1.0 / 2020-07-27

Initial release.
