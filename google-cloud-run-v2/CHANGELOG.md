# Changelog

### 0.13.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.13.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.13.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23784](https://github.com/googleapis/google-cloud-ruby/issues/23784)) 

### 0.12.0 (2023-09-29)

#### Features

* support cancel execution 
* support container overrides 
* support for Direct VPC egress setting 

### 0.11.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22923](https://github.com/googleapis/google-cloud-ruby/issues/22923)) 

### 0.10.1 (2023-08-04)

#### Documentation

* Improve documentation format ([#22684](https://github.com/googleapis/google-cloud-ruby/issues/22684)) 

### 0.10.0 (2023-07-10)

#### Features

* Adds support for custom audiences ([#22488](https://github.com/googleapis/google-cloud-ruby/issues/22488)) 

### 0.9.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.9.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21677](https://github.com/googleapis/google-cloud-ruby/issues/21677)) 

### 0.8.0 (2023-05-04)

#### Features

* Adds support for Session affinity in Service 
* Adds support for Startup CPU Boost 
* New 'port' field for HttpGetAction probe type 
* New fields/enum values 
#### Documentation

* General documentation fixes. 

### 0.7.0 (2023-03-08)

#### Features

* Support REST transport ([#20628](https://github.com/googleapis/google-cloud-ruby/issues/20628)) 

### 0.6.0 (2023-01-26)

#### Features

* Execution resource includes the cancelled and retried task counts 
* Execution resource provides the log URL 
* Revision resource includes the action to take when an encryption key is revoked ([#20055](https://github.com/googleapis/google-cloud-ruby/issues/20055)) 
#### Bug Fixes

* Set the request path params header correctly 

### 0.5.0 (2022-11-08)

#### Features

* support jobs and executions 
* support new IAM policy 

### 0.4.0 (2022-10-19)

#### Features

* Adds Startup and Liveness probes to Cloud Run v2 API client libraries ([#19288](https://github.com/googleapis/google-cloud-ruby/issues/19288)) 

### 0.3.1 (2022-09-15)

#### Documentation

* Fix the main client gem name listed in the readme ([#19166](https://github.com/googleapis/google-cloud-ruby/issues/19166)) 

### 0.3.0 (2022-07-07)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.2.0 (2022-05-10)

### ⚠ BREAKING CHANGES

* The previous version was mistakenly released using old interfaces; re-releasing using the correct interfaces

#### Bug Fixes

* The previous version was mistakenly released using old interfaces; re-releasing using the correct interfaces

### 0.1.0 (2022-05-05)

#### Features

* Initial generation of google-cloud-run-v2
