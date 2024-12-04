# Changelog

### 1.3.0 (2024-12-04)

#### Features

* Add EstablishPeering API for Onprem Migration 
* Add new Active Directory state for AD Diagnostics support 
* Add Sync API for Replications 
* Enable creation of Onprem Migration in CreateVolume ([#27656](https://github.com/googleapis/google-cloud-ruby/issues/27656)) 

### 1.2.0 (2024-09-19)

#### Features

* A new field 'allow_auto_tiering' in message 'google.cloud.netapp.v1.StoragePool' is added 
* A new field 'cold_tier_size_gib' in message 'google.cloud.netapp.v1.Volume' is added 
* A new message 'google.cloud.netapp.v1.SwitchActiveReplicaZoneRequest' is added 
* A new rpc 'SwitchActiveReplicaZone' is added to service 'google.cloud.netapp.v1.NetApp' ([#27329](https://github.com/googleapis/google-cloud-ruby/issues/27329)) 

### 1.1.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 1.1.0 (2024-08-02)

#### Features

* Support for ActiveDirectory administrators group 
* Support for replica zone and active zone in StoragePool and Volume 
* Support for Volume large_capacity and multiple_endpoints flags 
#### Documentation

* Various updates and clarifications in the reference documentation 

### 1.0.0 (2024-07-10)

#### Features

* Bump version to 1.0.0 

### 0.6.0 (2024-05-23)

#### Features

* BackupConfig reports the total byte size of a backup chain 
* Support for the Flex service level 
* Support for volume tiering policy 

### 0.5.2 (2024-04-15)

#### Documentation

* minor comment updates ([#25410](https://github.com/googleapis/google-cloud-ruby/issues/25410)) 

### 0.5.1 (2024-03-10)

#### Documentation

* mark optional fields explicitly in Storage Pool ([#25330](https://github.com/googleapis/google-cloud-ruby/issues/25330)) 

### 0.5.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24873](https://github.com/googleapis/google-cloud-ruby/issues/24873)) 

### 0.4.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.4.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.4.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23782](https://github.com/googleapis/google-cloud-ruby/issues/23782)) 

### 0.3.0 (2024-01-03)

#### Features

* Add support for Backup, Backup Vault, and Backup Policy ([#23687](https://github.com/googleapis/google-cloud-ruby/issues/23687)) 
* Set field_behavior to IDENTIFIER on the "name" fields 
#### Documentation

* Comments are updated for several fields/enums 

### 0.2.0 (2023-09-12)

#### Features

* Support for channel pool configuration 
* Support for restricting actions on a volume ([#23087](https://github.com/googleapis/google-cloud-ruby/issues/23087)) 
#### Bug Fixes

* Fixes for long running operations paths in the rest client 

### 0.1.0 (2023-09-05)

#### Features

* Initial generation of google-cloud-netapp-v1 ([#22689](https://github.com/googleapis/google-cloud-ruby/issues/22689)) 

## Release History
