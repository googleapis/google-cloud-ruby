# Changelog

### 0.6.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
* Support for new Cluster fields: gccs_source, managed_backup_source, cross_cluster_replication_config, maintenance_policy, maintenance_schedule, psc_service_attachments, cluster_endpoints, backup_collection, kms_key, automated_backup_config, and encryption_info 
* Support for the backup_cluster RPC 
* Support for the get_backup_collection and list_backup_collections RPCs 
* Support for the get_backup, list_backups, delete_backup, and export_backup RPCs 
* Support for the reschedule_cluster_maintenance RPC 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.5.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.4.2 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` ([#27011](https://github.com/googleapis/google-cloud-ruby/issues/27011)) 

### 0.4.1 (2024-08-08)

#### Documentation

* Formatting updates to README.md ([#26630](https://github.com/googleapis/google-cloud-ruby/issues/26630)) 

### 0.4.0 (2024-06-05)

#### Features

* Support for additional cluster configuration 
* Support for the get_cluster_certificate_authority RPC 

### 0.3.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24875](https://github.com/googleapis/google-cloud-ruby/issues/24875)) 

### 0.2.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.2.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.2.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23784](https://github.com/googleapis/google-cloud-ruby/issues/23784)) 

### 0.1.0 (2023-11-14)

#### Features

* Initial generation of google-cloud-redis-cluster-v1 ([#23531](https://github.com/googleapis/google-cloud-ruby/issues/23531)) 

## Release History
