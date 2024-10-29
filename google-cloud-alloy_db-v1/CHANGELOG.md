# Changelog

### 0.10.0 (2024-10-25)

#### Features

* add more observability options on the Instance level 
* add new API to execute SQL statements 
* add new API to list the databases in a project and location 
* add new API to perform a promotion or switchover on secondary instances 
* add new PSC instance configuration setting and output the PSC DNS name ([#27460](https://github.com/googleapis/google-cloud-ruby/issues/27460)) 
* add optional field to keep extra roles on a user if it already exists 
* add support for Free Trials 
* add support to schedule maintenance 
* additional field to set tags on a backup or cluster 
* support for obtaining the public ip addresses of an instance and enabling either inbound or outbound public ip 
#### Documentation

* various typo fixes, correcting the formatting, and clarifications on the request_id and validate_only fields in API requests and on the page_size when listing the database 

### 0.9.2 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` ([#27002](https://github.com/googleapis/google-cloud-ruby/issues/27002)) 

### 0.9.1 (2024-08-09)

#### Documentation

* Formatting updates ([#26623](https://github.com/googleapis/google-cloud-ruby/issues/26623)) 

### 0.9.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24862](https://github.com/googleapis/google-cloud-ruby/issues/24862)) 

### 0.8.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.8.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.8.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23772](https://github.com/googleapis/google-cloud-ruby/issues/23772)) 

### 0.7.0 (2023-11-06)

#### Features

* Add "use_metadata_exchange" field in GenerateClientCertificate API ([#23505](https://github.com/googleapis/google-cloud-ruby/issues/23505)) 

### 0.6.0 (2023-09-29)

#### Features

* support generate client certificate and get connection info for auth proxy 

### 0.5.0 (2023-09-22)

#### Features

* Add NetworkConfig, ClientConnectionConfig, QuantityBasedExpiry, DatabaseVersion 
* Add NetworkConfig, ClientConnectionConfig, QuantityBasedExpiry, DatabaseVersion ([#23341](https://github.com/googleapis/google-cloud-ruby/issues/23341)) 
#### Documentation

* Change description for recovery_window_days in ContinuousBackupConfig 

### 0.4.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22916](https://github.com/googleapis/google-cloud-ruby/issues/22916)) 

### 0.3.0 (2023-06-19)

#### Features

* Support ALLOW_UNENCRYPTED_AND_ENCRYPTED and ENCRYPTED_ONLY ssl modes 
* Support for continuous backups 
* Support for managing users ([#22383](https://github.com/googleapis/google-cloud-ruby/issues/22383)) 
* Support for the create_secondary_cluster RPC 
* Support for the create_secondary_instance RPC 
* Support for the inject_fault RPC 
* Support for the promote_cluster RPC 
* Support for views of a cluster 

### 0.2.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21671](https://github.com/googleapis/google-cloud-ruby/issues/21671)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.1.0 (2023-03-21)

#### Features

* Enable REST transport ([#20954](https://github.com/googleapis/google-cloud-ruby/issues/20954)) 
* Initial generation of google-cloud-alloy_db-v1 ([#20944](https://github.com/googleapis/google-cloud-ruby/issues/20944)) 

## Release History
