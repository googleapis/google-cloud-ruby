# Changelog

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
