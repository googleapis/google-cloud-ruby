# Release History

### 0.6.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.6.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.6.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.6.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.5.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.4.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.4.0 / 2020-12-15

#### Features

* Add path helpers for cluster resources

### 0.3.0 / 2020-12-02

#### ⚠ BREAKING CHANGES

* The `DOCKER` and `FLINK` values have been removed from the `Component` enum, and an `HBASE` value was added.

#### Features

* There is a new `temp_bucket` field in `ClusterConfig`.
* There is a new `preemptibility` field in `InstanceGroupConfig`.
* The `project_id` field of `JobReference` is now optional instead of required.
* There is a new `dag_timeout` field in `WorkflowTemplate`.
* There are new `dag_timeout`, `dag_start_time`, and `dag_end_time` fields in `WorkflowMetadata`.
* There are various updates to the doc comments.

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

#### Documentation

* change relative URLs to absolute URLs to fix broken links.

### 0.2.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file
* The long-running operations client honors the quota_project config

### 0.2.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.1.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.1.0 / 2020-04-23

Initial release.
