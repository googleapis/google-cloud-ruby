# Release History

### 0.15.0 (2022-09-08)

#### Features

* add location to WriteStream and add WriteStreamView support ([#19129](https://github.com/googleapis/google-cloud-ruby/issues/19129)) 

### 0.14.0 (2022-08-18)

#### Features

* Support for setting Apache Avro output format options ([#19034](https://github.com/googleapis/google-cloud-ruby/issues/19034)) 

### 0.13.0 (2022-07-28)

#### Features

* add support of preferred_min_stream_count 

### 0.12.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.11.1 (2022-06-28)

#### Bug Fixes

* Modify client lib retry policy for CreateWriteStream with longer backoff, more error code and longer overall time ([#18424](https://github.com/googleapis/google-cloud-ruby/issues/18424)) 

### 0.11.0 (2022-06-22)

#### Features

* add row error field to fields

### 0.10.1 / 2022-04-01

#### Documentation

* Mark row_count fields deprecated in the Read API

### 0.10.0 / 2022-03-03

#### Features

* Add trace_id to ReadSession ([#17679](https://www.github.com/googleapis/google-cloud-ruby/issues/17679))

### 0.9.2 / 2022-02-18

#### Bug Fixes

* We no longer request the unnecessary bigquery.readonly scope

### 0.9.1 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.9.0 / 2021-12-08

#### Features

* Added write mode support

### 0.8.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.8.0 / 2021-10-18

#### Features

* Support for the BigQuery Write service

### 0.7.0 / 2021-09-23

#### Features

* Return estimated total bytes scanned for a ReadSession

### 0.6.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.6.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.6.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.6.0 / 2021-05-21

#### Features

* Add ZSTD compression as an option for Arrow

### 0.5.0 / 2021-04-05

#### Features

* Add Arrow compression option, and return the schema on the first read_rows response

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

* Fix retries by converting error names to integer codes

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

### 0.1.4 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.1.3 / 2020-04-13

#### Documentation

* Various documentation and other updates.
  * Expanded the readme to include quickstart and logging information.
  * Added documentation for package and service modules.
  * Fixed and expanded documentation for the two method calling conventions.
  * Fixed some circular require warnings.

### 0.1.2 / 2020-04-09

#### Documentation

* Fix a broken link to IPC serialization information.

### 0.1.1 / 2020-04-01

#### Documentation

* Update documentation for core proto types.

### 0.1.0 / 2020-03-25

Initial release.
