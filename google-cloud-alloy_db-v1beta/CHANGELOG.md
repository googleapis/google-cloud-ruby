# Changelog

### 0.8.0 (2024-02-28)

#### Features

* support for getting PSC DNS name from the GetConnectionInfo API 
* Support for instance level network configuration 
* Support for instance level Private Service Connect configuration 
* Support for obtaining the public IP address of an instance 
* Support for the list_databases RPC ([#25264](https://github.com/googleapis/google-cloud-ruby/issues/25264)) 

### 0.7.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24862](https://github.com/googleapis/google-cloud-ruby/issues/24862)) 

### 0.6.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.6.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.6.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23772](https://github.com/googleapis/google-cloud-ruby/issues/23772)) 

### 0.5.0 (2023-09-25)

#### Features

* Add ClientConnectionConfig, QuantityBasedExpiry, DatabaseVersion 
* Add enum value for PG15 
* Add enum value for PG15 ([#23344](https://github.com/googleapis/google-cloud-ruby/issues/23344)) 
* Change description for recovery_window_days in ContinuousBackupConfig 
* Deprecate network field in favor of network_config.network 

### 0.4.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22916](https://github.com/googleapis/google-cloud-ruby/issues/22916)) 

### 0.3.0 (2023-06-16)

#### Features

* Generating client certificates provides the CA X.509 certificate 
* Support ALLOW_UNENCRYPTED_AND_ENCRYPTED and ENCRYPTED_ONLY ssl modes 
* Support for cluster network configuration 
* Support for earliest restorable time 
* Support for instance update policy 
* Support for managing users ([#22382](https://github.com/googleapis/google-cloud-ruby/issues/22382)) 
* Support for public key when generating client certificates 
* Support for the inject_fault RPC 
* Support for views of a cluster 

### 0.2.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21671](https://github.com/googleapis/google-cloud-ruby/issues/21671)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.1.0 (2023-03-21)

#### Features

* Initial generation of google-cloud-alloy_db-v1beta ([#20945](https://github.com/googleapis/google-cloud-ruby/issues/20945)) 

## Release History
