# Changelog

### 0.8.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23788](https://github.com/googleapis/google-cloud-ruby/issues/23788)) 

### 0.7.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22925](https://github.com/googleapis/google-cloud-ruby/issues/22925)) 

### 0.6.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.6.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21680](https://github.com/googleapis/google-cloud-ruby/issues/21680)) 

### 0.5.0 (2023-03-08)

#### Features

* Support REST transport ([#20630](https://github.com/googleapis/google-cloud-ruby/issues/20630)) 

### 0.4.0 (2023-01-11)

#### Features

* Added support for AWS as a source ([#19978](https://github.com/googleapis/google-cloud-ruby/issues/19978)) 
* Added support for get_replication_cycle and list_replication_cycles RPCs 
* Added support for retrieving the steps of a clone or cutover job 
* Added support for the IAM mixin client 
* Added support for the locations mixin client 

### 0.3.0 (2022-07-20)

#### Features

* Return additional_licenses and hostname in ComputeEngineTargetDefaults and ComputeEngineTargetDetails resources 
* Return appliance_infrastructure_version, appliance_software_version, available_versions, and upgrade_status in DatacenterConnector resources 
* Return recent_clone_jobs and recent_cutover_jobs in MigratingVm resources 
* Return the end_time in CloneJob and CutoverJob resources 
* Support for the upgrade_appliance call ([#18847](https://github.com/googleapis/google-cloud-ruby/issues/18847)) 
* Support the view argument for get_migrating_vm and list_migrating_vms 

### 0.2.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.1.1 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.1.0 / 2021-12-07

#### Features

* Initial generation of google-cloud-vm_migration-v1
