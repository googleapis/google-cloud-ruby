# Changelog

### 0.14.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Formatting update ([#28211](https://github.com/googleapis/google-cloud-ruby/issues/28211)) 
* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.13.0 (2025-01-08)

#### Features

* Support built-in Cloud Logging and Monitoring for Attached Clusters 
* Support tags on AttachedCluster resources 

### 0.12.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.11.0 (2024-09-19)

#### Features

* An optional field `kubelet_config` in message `.google.cloud.gkemulticloud.v1.AwsNodePool` is added 
* An optional field `security_posture_config` in message `.google.cloud.gkemulticloud.v1.AttachedCluster` is added ([#27330](https://github.com/googleapis/google-cloud-ruby/issues/27330)) 

### 0.10.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 0.10.0 (2024-05-15)

#### Features

* Support ignore_errors option to delete_azure_cluster and delete_azure_node_pool ([#25880](https://github.com/googleapis/google-cloud-ruby/issues/25880)) 

### 0.9.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24871](https://github.com/googleapis/google-cloud-ruby/issues/24871)) 

### 0.8.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.8.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.8.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23780](https://github.com/googleapis/google-cloud-ruby/issues/23780)) 

### 0.7.0 (2024-01-03)

#### Features

* add proxy support for Attached Clusters ([#23670](https://github.com/googleapis/google-cloud-ruby/issues/23670)) 
* add support for a new admin-groups flag in the create and update APIs 
* add support for per-node-pool subnet security group rules for AWS Node Pools 
* add Surge Update and Rollback support for AWS Node Pools 

### 0.6.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22920](https://github.com/googleapis/google-cloud-ruby/issues/22920)) 

### 0.5.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21675](https://github.com/googleapis/google-cloud-ruby/issues/21675)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.4.0 (2023-02-13)

#### Features

* Added reconciling and update_time output fields to Azure Client resource 
* Added support for Azure workload identity federation ([#20113](https://github.com/googleapis/google-cloud-ruby/issues/20113)) 

### 0.3.0 (2023-01-05)

#### Features

* Added verb and requested cancellation to operation metadata 
* Support for configuring autoscaling metrics collection for an AWS node 
* Support for managing Attached Clusters ([#19904](https://github.com/googleapis/google-cloud-ruby/issues/19904)) 
* Support for reporting errors from an AWS or Azure cluster 
* Support for setting the monitoring configuration for an AWS or Azure cluster 

### 0.2.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.1.0 (2022-05-22)

#### Features

* Initial generation of google-cloud-gke_multi_cloud-v1
