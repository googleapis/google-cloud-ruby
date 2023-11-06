# Release History

### 0.19.0 (2023-11-06)

#### Features

* Support DirectedReadOptions ([#23500](https://github.com/googleapis/google-cloud-ruby/issues/23500)) 

### 0.18.0 (2023-11-02)

#### Features

* Add PG_OID annotation for postgresql compatibility ([#23482](https://github.com/googleapis/google-cloud-ruby/issues/23482)) 

### 0.17.0 (2023-09-28)

#### Features

* support BatchWrite API 

### 0.16.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22924](https://github.com/googleapis/google-cloud-ruby/issues/22924)) 

### 0.15.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.15.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21678](https://github.com/googleapis/google-cloud-ruby/issues/21678)) 

### 0.14.1 (2023-03-20)

#### Bug Fixes

* Correct the proto ID for the data_boost_enabled field ([#20922](https://github.com/googleapis/google-cloud-ruby/issues/20922)) 

### 0.14.0 (2023-03-05)

#### Features

* add support for data_boost_enabled ([#20592](https://github.com/googleapis/google-cloud-ruby/issues/20592)) 

### 0.13.0 (2022-10-24)

#### Features

* Support for specifying a read lock mode for a read-write transaction ([#19311](https://github.com/googleapis/google-cloud-ruby/issues/19311)) 

### 0.12.0 (2022-10-18)

#### Features

* support undeclared_parameters in result set 

### 0.11.0 (2022-08-29)

#### Features

* Added a type annotation for PostgreSQL compatible JSONB ([#19086](https://github.com/googleapis/google-cloud-ruby/issues/19086)) 

### 0.10.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.9.0 (2022-06-08)

#### Features

* Added creator_role field to Session

### 0.8.1 / 2022-03-21

#### Bug Fixes

* remove unused imports

### 0.8.0 / 2022-02-15

#### Features

* Support for database dialects

### 0.7.4 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.7.3 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.7.2 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.7.1 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.7.0 / 2021-06-24

#### Features

* Add support for the JSON type

### 0.6.1 / 2021-06-23

#### Bug Fixes

* Moved CommitResponse into a separate proto file
* Support future 1.x versions of gapic-common

### 0.6.0 / 2021-04-05

#### Features

* Add tagging to request options
* Support for priority request options

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0
* Support setting of the query optimizer statistics package

### 0.4.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.3.0 / 2021-01-26

#### Features

* Add option for returning Spanner commit stats

### 0.2.3 / 2021-01-20

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.2 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.2.1 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.2.0 / 2020-07-16

#### Features

* Support NUMERIC type

### 0.1.0 / 2020-07-06

Initial release.
