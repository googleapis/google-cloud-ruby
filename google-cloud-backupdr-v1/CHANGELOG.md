# Changelog

### 1.1.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 1.0.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 1.0.0 (2025-02-07)

### ⚠ BREAKING CHANGES

* Fixed incorrect pagination on certain REST RPC methods ([#28823](https://github.com/googleapis/google-cloud-ruby/issues/28823))

#### Features

* Bump version to 1.0.0 ([#28941](https://github.com/googleapis/google-cloud-ruby/issues/28941)) 
#### Bug Fixes

* Fixed incorrect pagination on certain REST RPC methods ([#28823](https://github.com/googleapis/google-cloud-ruby/issues/28823)) 

### 0.5.0 (2025-01-28)

#### Features

* Support for the initialize_service RPC 
* The delete_backup_vault RPC supports the ignore_backup_plan_references parameter 
* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.4.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.3.0 (2024-12-04)

#### Features

* Add backupplan proto 
* Add backupplanassociation proto 
* Add backupvault_ba proto 
* Add backupvault_gce proto 
* Client library for the backupvault api is added ([#27363](https://github.com/googleapis/google-cloud-ruby/issues/27363)) 
#### Documentation

* A comment for field `management_servers` in message `.google.cloud.backupdr.v1.ListManagementServersResponse` is changed 
* A comment for field `name` in message `.google.cloud.backupdr.v1.GetManagementServerRequest` is changed 
* A comment for field `oauth2_client_id` in message `.google.cloud.backupdr.v1.ManagementServer` is changed 
* A comment for field `parent` in message `.google.cloud.backupdr.v1.CreateManagementServerRequest` is changed 
* A comment for field `parent` in message `.google.cloud.backupdr.v1.ListManagementServersRequest` is changed 
* A comment for field `requested_cancellation` in message `.google.cloud.backupdr.v1.OperationMetadata` is changed 

### 0.2.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 0.2.0 (2024-06-25)

#### Features

* A new field `satisfies_pzi` is added 
* A new field `satisfies_pzs` is added 
* Updated documentation URI 

### 0.1.0 (2024-04-18)

#### Features

* Initial generation of google-cloud-backupdr-v1 ([#25702](https://github.com/googleapis/google-cloud-ruby/issues/25702)) 

## Release History
