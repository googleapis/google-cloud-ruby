# Changelog

### 1.1.0 (2024-12-04)

#### Features

* A new enum `TableType` is added 
* A new field `datascan_id` is added to message `.google.cloud.dataplex.v1.DiscoveryEvent` 
* A new field `suspended` is added to DataScans 
* A new field `table` is added to message `.google.cloud.dataplex.v1.DiscoveryEvent` 
* A new message `TableDetails` is added 
* Add a DATA_DISCOVERY enum type in DataScanEvent 
* Add a DataDiscoveryAppliedConfigs message 
* Add a TABLE_DELETED field in DiscoveryEvent 
* Add a TABLE_IGNORED field in DiscoveryEvent 
* Add a TABLE_PUBLISHED field in DiscoveryEvent 
* Add a TABLE_UPDATED field in DiscoveryEvent 
* Add an Issue field to DiscoveryEvent.ActionDetails to output the action message in Cloud Logs 
* add annotations in CreateMetadataJob, GetMetadataJob, ListMetaDataJobs and CancelMetadataJob for cloud audit logging 
* Add data_version field to AspectSource 
* Add new Data Discovery scan type in Datascan 
* expose create time in DataScanJobAPI 
* expose create time to customers 
* release metadata export in private preview 
* release MetadataJob APIs and related resources in GA 
* update Go Bigtable import path 
* update Go Datastore import path ([#27636](https://github.com/googleapis/google-cloud-ruby/issues/27636)) 
#### Documentation

* A comment for message `DataScanEvent` is changed 
* Add comment for field `status` in message `.google.cloud.dataplex.v1.MetadataJob` per https://linter.aip.dev/192/has-comments 
* Add comment for field `type` in message `.google.cloud.dataplex.v1.MetadataJob` per https://linter.aip.dev/192/has-comments 
* Add Identifier for `name` in message `.google.cloud.dataplex.v1.MetadataJob` per https://google.aip.dev/cloud/2510 
* add info about schema changes for BigQuery metadata in Dataplex Catalog 
* Add link to fully qualified names documentation 
* correct API documentation 
* correct the dimensions for data quality rules 
* Dataplex Tasks do not support Dataplex Content path as a direct input anymore 
* Scrub descriptions for standalone discovery scans 

### 1.0.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 1.0.0 (2024-07-10)

#### Features

* Bump version to 1.0.0 

### 0.23.0 (2024-06-28)

#### Features

* expose data scan execution create time to customers ([#26243](https://github.com/googleapis/google-cloud-ruby/issues/26243)) 

### 0.22.0 (2024-06-25)

#### Features

* Support resource location field in EntrySource ([#26142](https://github.com/googleapis/google-cloud-ruby/issues/26142)) 

### 0.21.1 (2024-06-18)

#### Documentation

* Marked linked_resource and snippets as deprecated in SearchEntriesResult ([#26126](https://github.com/googleapis/google-cloud-ruby/issues/26126)) 

### 0.21.0 (2024-05-23)

#### Features

* Support SQL Assertion data quality rules ([#25838](https://github.com/googleapis/google-cloud-ruby/issues/25838)) 

### 0.20.0 (2024-04-19)

#### Features

* Support Unified Metastore and CRUD Metastore (e.g. EntryGroup, AspectType, EntryType) ([#25409](https://github.com/googleapis/google-cloud-ruby/issues/25409)) 

### 0.19.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24868](https://github.com/googleapis/google-cloud-ruby/issues/24868)) 

### 0.18.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.18.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.18.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23777](https://github.com/googleapis/google-cloud-ruby/issues/23777)) 

### 0.17.0 (2024-01-03)

#### Features

* add new field GOVERNANCE_RULE_PROCESSING to enum EventType ([#23671](https://github.com/googleapis/google-cloud-ruby/issues/23671)) 

### 0.16.0 (2023-12-07)

#### Features

* add data quality score to DataQualityResult ([#23583](https://github.com/googleapis/google-cloud-ruby/issues/23583)) 

### 0.15.0 (2023-12-04)

#### Features

* support more event types 
* support score, dimension_score, colun_score for DataQualityResult 

### 0.14.0 (2023-11-02)

#### Features

* Support GovernanceEvent ([#23489](https://github.com/googleapis/google-cloud-ruby/issues/23489)) 

### 0.13.0 (2023-10-16)

#### Features

* Added dimension to DataQualityDimensionResult ([#23427](https://github.com/googleapis/google-cloud-ruby/issues/23427)) 

### 0.12.0 (2023-09-26)

#### Features

* additional HTTP bindings for IAM methods ([#23353](https://github.com/googleapis/google-cloud-ruby/issues/23353)) 

### 0.11.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22919](https://github.com/googleapis/google-cloud-ruby/issues/22919)) 

### 0.10.1 (2023-08-15)

#### Bug Fixes

* remove unused annotation in results_table ([#22746](https://github.com/googleapis/google-cloud-ruby/issues/22746)) 

### 0.10.0 (2023-08-01)

#### Features

* support DataTaxonomyService ([#22585](https://github.com/googleapis/google-cloud-ruby/issues/22585)) 

### 0.9.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21674](https://github.com/googleapis/google-cloud-ruby/issues/21674)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.8.0 (2023-05-04)

#### Features

* Added DataSource#resource 
* Added Entity#access and Entity#uid 
* Added ResourceSpec#read_access_mode 
* Added ResourceStatus#managed_access_identity 
* Support for the run_task call 
* The create_data_scan and update_data_scan support the validate_only flag 

### 0.7.0 (2023-03-08)

#### Features

* Support REST transport ([#20625](https://github.com/googleapis/google-cloud-ruby/issues/20625)) 

### 0.6.1 (2023-02-03)

#### Documentation

* Improve to DataScan API documentation ([#20105](https://github.com/googleapis/google-cloud-ruby/issues/20105)) 

### 0.6.0 (2023-01-05)

#### Features

* Support for DataScanService ([#19952](https://github.com/googleapis/google-cloud-ruby/issues/19952)) 
* Support for Iceberg Tables 

### 0.5.1 (2022-12-15)

#### Documentation

* Minor fixes to reference documentation formatting ([#19875](https://github.com/googleapis/google-cloud-ruby/issues/19875)) 

### 0.5.0 (2022-10-18)

#### Features

* Add event_succeeded, fast_startup_enabled, unassigned_duration to SessionEvent 
* Support notebook configurations ([#19242](https://github.com/googleapis/google-cloud-ruby/issues/19242)) 
* Support the CREATE event type 

### 0.4.0 (2022-07-19)

#### Features

* Added ContainerImageRuntime#image 
* Added filter argument to list_sessions request 
* Added project and KMS key to ExecutionSpec 
* Added sampled_data_locations to partition details 
* Added support for Locations and IAMPolicy auxiliary clients ([#18838](https://github.com/googleapis/google-cloud-ruby/issues/18838)) 
* Support for returning task execution status 

### 0.3.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.2.1 (2022-05-03)

#### Bug Fixes

* Removed a few unused requires

### 0.2.0 / 2022-02-17

#### Features

* Support for management of Notebook and SQL Scripts
* Support for management of environment resources
* Support for listing sessions in an environment
* Support for creating, updating, and deleting metadata entities
* Support for creating and deleting metadata partitions

### 0.1.0 / 2022-02-15

#### Features

* Initial generation of google-cloud-dataplex-v1
