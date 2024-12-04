# Changelog

### 0.19.0 (2024-12-04)

#### Features

* Support for manual instance count ([#27649](https://github.com/googleapis/google-cloud-ruby/issues/27649)) 

### 0.18.0 (2024-11-13)

#### Features

* Add EncryptionKeyRevocationAction and shutdown duration configuration to Services ([#27604](https://github.com/googleapis/google-cloud-ruby/issues/27604)) 
* support advanced configurations options for cloud storage volumes by setting `mount_options` in the GCSVolumeSource configuration ([#27583](https://github.com/googleapis/google-cloud-ruby/issues/27583)) 
#### Documentation

* A comment for field `max_instance_request_concurrency` in message `.google.cloud.run.v2.RevisionTemplate` is changed 
* For field `invoker_iam_disabled` in message `.google.cloud.run.v2.Service`, clarify that feature is available by invitation only 
* formatting updates 
* Update docs for field `value` in message `.google.cloud.run.v2.EnvVar` to reflect Cloud Run product capabilities 

### 0.17.0 (2024-10-15)

#### Features

* Services now report all URLs serving traffic 
* Support for disabling IAM permission check for invokers 
* Support for revision node selector 
* Support for service mesh connectivity 
* Support for service scaling modes 
* Support for the Builds service and submit_build RPC 

### 0.16.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` ([#27011](https://github.com/googleapis/google-cloud-ruby/issues/27011)) 

### 0.16.0 (2024-07-10)

#### Features

* add Job ExecutionReference.completion_status to show status of the most recent execution 
* add Job start_execution_token and run_execution_token to execute jobs immediately on creation 
* support update_mask in Cloud Run UpdateService ([#26373](https://github.com/googleapis/google-cloud-ruby/issues/26373)) 
#### Documentation

* clarify optional fields in Cloud Run requests 

### 0.15.0 (2024-03-06)

#### Features

* allow disabling the default URL (run.app) for Cloud Run Services 
* support disabling waiting for health checks during Service deployment 
* support mounting NFS and GCS volumes in Cloud Run Jobs and Services 
* support specifying a per-Service min-instance-count and service scaling 

### 0.14.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24876](https://github.com/googleapis/google-cloud-ruby/issues/24876)) 

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
