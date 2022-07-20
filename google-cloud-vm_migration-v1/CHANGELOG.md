# Changelog

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
