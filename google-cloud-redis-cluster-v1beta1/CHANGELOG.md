# Changelog

### 0.6.0 (2025-09-11)

#### Features

* update gapic-common dependency for generated libraries to 1.2 which requires google-protobuf v4.26+ ([#31011](https://github.com/googleapis/google-cloud-ruby/issues/31011)) 

### 0.5.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 0.4.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 0.4.0 (2025-02-07)

### ⚠ BREAKING CHANGES

* Fixed incorrect pagination on certain REST RPC methods ([#28826](https://github.com/googleapis/google-cloud-ruby/issues/28826))

#### Bug Fixes

* Fixed incorrect pagination on certain REST RPC methods ([#28826](https://github.com/googleapis/google-cloud-ruby/issues/28826)) 

### 0.3.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
* Support for new Cluster fields: gccs_source, managed_backup_source, cross_cluster_replication_config, maintenance_policy, maintenance_schedule, psc_service_attachments, cluster_endpoints, backup_collection, kms_key, automated_backup_config, and encryption_info 
* Support for the backup_cluster RPC ([#28235](https://github.com/googleapis/google-cloud-ruby/issues/28235)) 
* Support for the get_backup_collection and list_backup_collections RPCs 
* Support for the get_backup, list_backups, delete_backup, and export_backup RPCs 
* Support for the reschedule_cluster_maintenance RPC 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.2.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.1.2 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` ([#27011](https://github.com/googleapis/google-cloud-ruby/issues/27011)) 

### 0.1.1 (2024-08-08)

#### Documentation

* Formatting updates to README.md ([#26630](https://github.com/googleapis/google-cloud-ruby/issues/26630)) 

### 0.1.0 (2024-06-07)

#### Features

* Initial generation of google-cloud-redis-cluster-v1beta1 ([#26076](https://github.com/googleapis/google-cloud-ruby/issues/26076)) 

## Release History
