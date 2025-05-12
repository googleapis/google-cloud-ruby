# Changelog

### 1.2.0 (2025-05-12)

#### Features

* A new field `async_instance_endpoints_deletion_enabled` is added to message `.google.cloud.memorystore.v1.Instance` 
* A new field `automated_backup_config` is added to message `.google.cloud.memorystore.v1.Instance` 
* A new field `backup_collection` is added to message `.google.cloud.memorystore.v1.Instance` 
* A new field `cross_instance_replication_config` is added to message `.google.cloud.memorystore.v1.Instance` 
* A new field `gcs_source` is added to message `.google.cloud.memorystore.v1.Instance` 
* A new field `maintenance_policy` is added to message `.google.cloud.memorystore.v1.Instance` 
* A new field `maintenance_schedule` is added to message `.google.cloud.memorystore.v1.Instance` 
* A new field `managed_backup_source` is added to message `.google.cloud.memorystore.v1.Instance` 
* A new field `ondemand_maintenance` is added to message `.google.cloud.memorystore.v1.Instance` 
* A new field `port` is added to message `.google.cloud.memorystore.v1.PscConnection` 
* A new field `psc_attachment_details` is added to message `.google.cloud.memorystore.v1.Instance` 
* A new field `target_engine_version` is added to message `.google.cloud.memorystore.v1.Instance` 
* A new field `target_node_type` is added to message `.google.cloud.memorystore.v1.Instance` 
* A new message `AutomatedBackupConfig` is added 
* A new message `Backup` is added 
* A new message `BackupCollection` is added 
* A new message `BackupFile` is added 
* A new message `BackupInstanceRequest` is added 
* A new message `CrossInstanceReplicationConfig` is added 
* A new message `DeleteBackupRequest` is added 
* A new message `ExportBackupRequest` is added 
* A new message `GcsBackupSource` is added 
* A new message `GetBackupCollectionRequest` is added 
* A new message `GetBackupRequest` is added 
* A new message `ListBackupCollectionsRequest` is added 
* A new message `ListBackupCollectionsResponse` is added 
* A new message `ListBackupsRequest` is added 
* A new message `ListBackupsResponse` is added 
* A new message `MaintenancePolicy` is added 
* A new message `MaintenanceSchedule` is added 
* A new message `ManagedBackupSource` is added 
* A new message `PscAttachmentDetail` is added 
* A new message `RescheduleMaintenanceRequest` is added 
* A new message `WeeklyMaintenanceWindow` is added 
* A new method `BackupInstance` is added to service `Memorystore` 
* A new method `DeleteBackup` is added to service `Memorystore` 
* A new method `ExportBackup` is added to service `Memorystore` 
* A new method `GetBackup` is added to service `Memorystore` 
* A new method `GetBackupCollection` is added to service `Memorystore` 
* A new method `ListBackupCollections` is added to service `Memorystore` 
* A new method `ListBackups` is added to service `Memorystore` 
* A new method `RescheduleMaintenance` is added to service `Memorystore` 
* A new resource_definition `cloudkms.googleapis.com/CryptoKey` is added 
* A new resource_definition `memorystore.googleapis.com/Backup` is added 
* A new resource_definition `memorystore.googleapis.com/BackupCollection` is added 
* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 
#### Bug Fixes

* Changed field behavior for an existing field `psc_connection_id` in message `.google.cloud.memorystore.v1.PscConnection` ([#30051](https://github.com/googleapis/google-cloud-ruby/issues/30051)) 
#### Documentation

* A comment for field `discovery_endpoints` in message `.google.cloud.memorystore.v1.Instance` is changed 
* A comment for field `engine_version` in message `.google.cloud.memorystore.v1.Instance` is changed 
* A comment for field `node_type` in message `.google.cloud.memorystore.v1.Instance` is changed 
* A comment for field `port` in message `.google.cloud.memorystore.v1.PscAutoConnection` is changed 
* A comment for field `psc_auto_connection` in message `.google.cloud.memorystore.v1.Instance` is changed 
* A comment for field `psc_auto_connections` in message `.google.cloud.memorystore.v1.Instance` is changed 
* A comment for field `psc_connection_id` in message `.google.cloud.memorystore.v1.PscConnection` is changed 

### 1.1.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 1.1.0 (2025-02-12)

#### Features

* Deprecated STANDALONE instance mode and replaced with CLUSTER_DISABLED ([#28961](https://github.com/googleapis/google-cloud-ruby/issues/28961)) 

### 1.0.0 (2025-02-07)

### ⚠ BREAKING CHANGES

* Fixed incorrect pagination on certain REST RPC methods ([#28825](https://github.com/googleapis/google-cloud-ruby/issues/28825))

#### Features

* Bump version to 1.0.0 ([#28941](https://github.com/googleapis/google-cloud-ruby/issues/28941)) 
#### Bug Fixes

* Fixed incorrect pagination on certain REST RPC methods ([#28825](https://github.com/googleapis/google-cloud-ruby/issues/28825)) 

### 0.3.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.2.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.1.0 (2024-12-09)

#### Features

* Initial generation of google-cloud-memorystore-v1 ([#27754](https://github.com/googleapis/google-cloud-ruby/issues/27754)) 

## Release History
