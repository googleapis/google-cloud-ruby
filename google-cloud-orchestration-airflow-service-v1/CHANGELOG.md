# Changelog

### 0.10.0 (2024-02-16)

#### Features

* add data_retention_config to EnvironmentConfig 
* add ListWorkloads RPC ([#24817](https://github.com/googleapis/google-cloud-ruby/issues/24817)) 
* add storage_config to Environment 
* add web_server_plugins_mode to SoftwareConfig 

### 0.9.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.9.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.9.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23782](https://github.com/googleapis/google-cloud-ruby/issues/23782)) 

### 0.8.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22922](https://github.com/googleapis/google-cloud-ruby/issues/22922)) 

### 0.7.0 (2023-06-16)

#### Features

* added support for StopAirflowCommand, ExecuteAirflowCommand, PollAirflowCommand, DatabaseFailover, FetchDatabaseProperties ([#22388](https://github.com/googleapis/google-cloud-ruby/issues/22388)) 

### 0.6.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.6.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21676](https://github.com/googleapis/google-cloud-ruby/issues/21676)) 

### 0.5.0 (2023-04-28)

#### Features

* Add airflow_byoid_uri field to EnvironmentConfig ([#21486](https://github.com/googleapis/google-cloud-ruby/issues/21486)) 

### 0.4.0 (2023-03-08)

#### Features

* Support REST transport ([#20627](https://github.com/googleapis/google-cloud-ruby/issues/20627)) 

### 0.3.1 (2023-02-13)

#### Documentation

* Minor formatting fixes to reference docs ([#20140](https://github.com/googleapis/google-cloud-ruby/issues/20140)) 

### 0.3.0 (2022-12-09)

#### Features

* Added support for load_snapshot and save_snapshot calls ([#19485](https://github.com/googleapis/google-cloud-ruby/issues/19485)) 

### 0.2.0 (2022-07-06)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.1.2 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.1.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.1.0 / 2021-09-27

#### Features

* Initial generation of google-cloud-orchestration-airflow-service-v1
