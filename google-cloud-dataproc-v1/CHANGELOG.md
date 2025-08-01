# Release History

### 1.6.0 (2025-07-15)

#### Features

* Support for creating premium clusters ([#30583](https://github.com/googleapis/google-cloud-ruby/issues/30583)) 

### 1.5.0 (2025-06-16)

#### Features

* add scenarios AUTO/NONE to autotuning config 
* Added support for DELTA, ICEBERG, PIG components ([#30496](https://github.com/googleapis/google-cloud-ruby/issues/30496)) 

### 1.4.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 1.3.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 1.3.0 (2025-02-25)

#### Features

* Support for authentication configuration in serverless workloads ([#29182](https://github.com/googleapis/google-cloud-ruby/issues/29182)) 

### 1.2.0 (2025-02-07)

#### Features

* Provide opt-in debug logging 
* Report batches that could not be included in a list_batches response 
* Report unreachable resources due to KMS-key-encrypted parameters that could not be decrypted 
* Support Apache Flink 
* Support configuring how the Group selects the provisioning model to ensure required reliability 
* Support configuring IOPS and throughput provisioning in DiskConfig 
* Support configuring the cloud KMS key resource name to use for cluster persistent disk and job argument encryption 
* Support encryption for workflow template job arguments 
* Support Spark Connect for interactive seesions 
* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 1.1.0 (2024-09-11)

#### Features

* Support for tarball_access parameter to the diagnose_cluster RPC ([#27287](https://github.com/googleapis/google-cloud-ruby/issues/27287)) 

### 1.0.2 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 1.0.1 (2024-08-08)

#### Documentation

* Formatting updates to README.md ([#26626](https://github.com/googleapis/google-cloud-ruby/issues/26626)) 

### 1.0.0 (2024-07-08)

#### Features

* Bump version to 1.0.0 

### 0.26.0 (2024-06-26)

#### Features

* Support cohort and auto tuning configuration in batch RuntimeConfig ([#26159](https://github.com/googleapis/google-cloud-ruby/issues/26159)) 

### 0.25.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24868](https://github.com/googleapis/google-cloud-ruby/issues/24868)) 

### 0.24.1 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.24.0 (2024-01-31)

#### Features

* add session and session_template controllers ([#24493](https://github.com/googleapis/google-cloud-ruby/issues/24493)) 

### 0.23.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.23.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23777](https://github.com/googleapis/google-cloud-ruby/issues/23777)) 

### 0.22.0 (2023-11-06)

#### Features

* Add startup_config field in InstanceGroupConfig ([#23507](https://github.com/googleapis/google-cloud-ruby/issues/23507)) 

### 0.21.0 (2023-09-19)

#### Features

* Support tarball_gcs_dir, diagnosis_interval, jos, and yarn_application_ids arguments to the diagnose_cluster call ([#23331](https://github.com/googleapis/google-cloud-ruby/issues/23331)) 

### 0.20.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22919](https://github.com/googleapis/google-cloud-ruby/issues/22919)) 

### 0.19.0 (2023-09-04)

#### Features

* support min_num_instances for primary worker and InstanceFlexibilityPolicy for secondary worker ([#22841](https://github.com/googleapis/google-cloud-ruby/issues/22841)) 

### 0.18.1 (2023-08-03)

#### Documentation

* Improve documentation format ([#22680](https://github.com/googleapis/google-cloud-ruby/issues/22680)) 

### 0.18.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21674](https://github.com/googleapis/google-cloud-ruby/issues/21674)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.17.0 (2023-03-08)

#### Features

* Support REST transport ([#20625](https://github.com/googleapis/google-cloud-ruby/issues/20625)) 

### 0.16.0 (2023-02-23)

#### Features

* ClusterOperationMetadata includes child operation IDs 
* Expose approximate and current batches resources usage 
* Include a mixin client for IAM policies 
* Include boot disk KMS key in GkeNodeConfig 
* Include GPU partition size in GkeNodePoolAcceleratorConfig 
* Include spot flag in GkeNodeConfig 
* Support batch TTL 
* Support custom staging bucket for batches 
* Support filtering and ordering in list_batches API 
* Support for the HIVEMETASTORE metric source 
* Support Hudi and Trino components ([#20497](https://github.com/googleapis/google-cloud-ruby/issues/20497)) 
* Support Trino jobs on 2.1+ image clusters 

### 0.15.0 (2023-01-24)

#### Features

* Support for the SPOT preemptibility option ([#20045](https://github.com/googleapis/google-cloud-ruby/issues/20045)) 

### 0.14.0 (2022-12-14)

#### Features

* Support for configuring driver scheduling in a Job 
* Support for setting auxiliary node groups in a ClusterConfig 
* Support for the NodeGroupController service ([#19853](https://github.com/googleapis/google-cloud-ruby/issues/19853)) 

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
