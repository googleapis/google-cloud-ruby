# Changelog

### 0.10.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 0.9.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 0.8.0 (2024-11-13)

### ⚠ BREAKING CHANGES

* deprecated various PSC instance configuration fields ([#27576](https://github.com/googleapis/google-cloud-ruby/issues/27576))

#### Features

* add more observability options on the Instance level 
* add new API to execute SQL statements 
* add new API to perform a promotion or switchover on secondary instances 
* add new API to upgrade a cluster 
* add new CloudSQL backup resource 
* add new cluster and instance level configurations to interact with Gemini 
* add new PSC instance configuration setting and output the PSC DNS name 
* add optional field to keep extra roles on a user if it already exists 
* add support for Free Trials 
* add support to schedule maintenance 
* additional field to set tags on a backup or cluster 
* support for obtaining the public ip addresses of an instance and enabling outbound public ip 
#### Bug Fixes

* deprecated various PSC instance configuration fields ([#27576](https://github.com/googleapis/google-cloud-ruby/issues/27576)) 
#### Documentation

* various typo fixes, correcting the formatting, and clarifications on the request_id and validate_only fields in API requests and on the page_size when listing the database 

### 0.7.2 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` ([#27002](https://github.com/googleapis/google-cloud-ruby/issues/27002)) 

### 0.7.1 (2024-08-09)

#### Documentation

* Formatting updates ([#26623](https://github.com/googleapis/google-cloud-ruby/issues/26623)) 

### 0.7.0 (2024-02-28)

#### Features

* support for getting PSC DNS name from the GetConnectionInfo API 
* Support for obtaining the public IP address of an instance ([#25263](https://github.com/googleapis/google-cloud-ruby/issues/25263)) 

### 0.6.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24862](https://github.com/googleapis/google-cloud-ruby/issues/24862)) 

### 0.5.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.5.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.5.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23772](https://github.com/googleapis/google-cloud-ruby/issues/23772)) 

### 0.4.0 (2024-01-03)

#### Features

* add instance network config 
* add ListDatabases API and Database object 
* add PSC config, PSC interface config, PSC instance config ([#23674](https://github.com/googleapis/google-cloud-ruby/issues/23674)) 
* add support for fields satisfies_pzi and satisfies_pzs 
* change field network in NetworkConfig from required to optional 

### 0.3.0 (2023-09-26)

#### Features

* support client connection configuration, database_version and add POSTGRES_15 for Backup 

### 0.2.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22916](https://github.com/googleapis/google-cloud-ruby/issues/22916)) 

### 0.1.0 (2023-07-14)

#### Features

* Initial generation of google-cloud-alloy_db-v1alpha ([#22527](https://github.com/googleapis/google-cloud-ruby/issues/22527)) 

## Release History
