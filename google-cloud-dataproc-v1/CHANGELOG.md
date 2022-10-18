# Release History

### 0.13.0 (2022-09-28)

#### Features

* Support for dataproc metric configuration ([#19209](https://github.com/googleapis/google-cloud-ruby/issues/19209)) 

### 0.12.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.11.0 (2022-06-30)

#### Features

* support OLM Prefix/Suffix ([#18190](https://github.com/googleapis/google-cloud-ruby/issues/18190)) 

### 0.10.0 (2022-05-12)

#### Bug Fixes

* BREAKING CHANGE: Remove unused VirtualClusterConfig#temp_bucket field

### 0.9.0 / 2022-02-17

#### Features

* **BREAKING CHANGE:** Replaced the temporary gke_cluster_config field with the permanent virtual_cluster_config

### 0.8.0 / 2022-01-11

#### Features

* Additional fields for DiskConfig and RuntimeInfo

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.7.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.7.0 / 2021-10-21

#### Features

* Add support for batch workloads

### 0.6.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.6.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.6.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.6.0 / 2021-04-26

#### Features

* Support for stop_cluster and start_cluster, along with additional options for jobs and workflow templates

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.4.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.3.2 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.3.1 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.3.0 / 2020-08-06

#### Features

* Support cluster endpoint configs and instance group preemptibility

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

#### Documentation

* Fix broken links in the AutoscalingPolicies documentation.

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
