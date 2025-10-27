# Changelog

### 0.11.1 (2025-10-27)

#### Documentation

* add warning about loading unvalidated credentials 

### 0.11.0 (2025-10-22)

#### Features

* Expand Oracle Database v1 API to add support for Exadata Exascale (`ExadbVmCluster`, `ExascaleDbStorageVault`), Base Database (`DbSystem`, `Database`, `PluggableDatabase`), and Networking (`OdbNetwork`, `OdbSubnet`). ([#31792](https://github.com/googleapis/google-cloud-ruby/issues/31792)) 
#### Documentation

* Updated comments for clarity and fixed typos 

### 0.10.0 (2025-10-08)

#### Features

* add ListOperations partial success flag ([#31580](https://github.com/googleapis/google-cloud-ruby/issues/31580)) 
* add ListOperations unreachable resources 

### 0.9.0 (2025-09-11)

#### Features

* update gapic-common dependency for generated libraries to 1.2 which requires google-protobuf v4.26+ ([#31011](https://github.com/googleapis/google-cloud-ruby/issues/31011)) 

### 0.8.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 0.7.0 (2025-04-29)

#### Features

* Added support for gRPC transport ([#30029](https://github.com/googleapis/google-cloud-ruby/issues/30029)) 
#### Bug Fixes

* Fixed several issues with validating credential configs 

### 0.6.0 (2025-04-18)

#### Features

* add new AutonomousDatabase RPCs ([#29464](https://github.com/googleapis/google-cloud-ruby/issues/29464)) 

### 0.5.1 (2025-03-25)

#### Documentation

* The network and cidr fields of AutonomousDatabase are now marked optional ([#29396](https://github.com/googleapis/google-cloud-ruby/issues/29396)) 

### 0.5.0 (2025-03-18)

#### Features

* Added entitlement state for not approved in private marketplace ([#29359](https://github.com/googleapis/google-cloud-ruby/issues/29359)) 

### 0.4.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.3.0 (2025-01-09)

#### Features

* Support new ACCOUNT_SUSPENDED state in Entitlement ([#28208](https://github.com/googleapis/google-cloud-ruby/issues/28208)) 

### 0.2.1 (2025-01-08)

#### Documentation

* the CloudVmClusterProperties#system_version field is no longer labeled as output only ([#28178](https://github.com/googleapis/google-cloud-ruby/issues/28178)) 

### 0.2.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.1.0 (2024-10-03)

#### Features

* Initial general of google-cloud-oracle_database-v1 ([#27396](https://github.com/googleapis/google-cloud-ruby/issues/27396)) 

## Release History
