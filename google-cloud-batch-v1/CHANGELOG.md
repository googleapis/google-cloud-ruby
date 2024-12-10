# Changelog

### 0.20.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 
#### Documentation

* Clarified some options for logs ([#27745](https://github.com/googleapis/google-cloud-ruby/issues/27745)) 

### 0.19.2 (2024-12-04)

#### Documentation

* Revised labels and reservation field descriptions ([#27680](https://github.com/googleapis/google-cloud-ruby/issues/27680)) 

### 0.19.1 (2024-10-02)

#### Documentation

* Clarify Batch only supports global custom instance template now ([#27390](https://github.com/googleapis/google-cloud-ruby/issues/27390)) 

### 0.19.0 (2024-09-11)

#### Features

* Support for blocking project-level SSH keys ([#27288](https://github.com/googleapis/google-cloud-ruby/issues/27288)) 

### 0.18.3 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 0.18.2 (2024-08-22)

#### Documentation

* Batch CentOS images and HPC CentOS images are EOS 
* Clarify required fields for Runnable.Container 
* Clarify required oneof fields for Runnable.Script 
* clarify tasks success criteria for background runnable ([#26962](https://github.com/googleapis/google-cloud-ruby/issues/26962)) 
* Clarify TaskSpec requires one or more runnables 

### 0.18.1 (2024-08-06)

#### Documentation

* Refine usage scope for fields `task_execution` and `task_state` in StatusEvent ([#26607](https://github.com/googleapis/google-cloud-ruby/issues/26607)) 

### 0.18.0 (2024-06-26)

#### Features

* Add install_ops_agent field to InstancePolicyOrTemplate for Ops Agent support ([#26180](https://github.com/googleapis/google-cloud-ruby/issues/26180)) 

### 0.17.4 (2024-06-05)

#### Documentation

* Minor documentation updates ([#26047](https://github.com/googleapis/google-cloud-ruby/issues/26047)) 

### 0.17.3 (2024-05-23)

#### Documentation

* Update description for TaskExecution#exit_code ([#25908](https://github.com/googleapis/google-cloud-ruby/issues/25908)) 
* Update description on allowed_locations in LocationPolicy field ([#25827](https://github.com/googleapis/google-cloud-ruby/issues/25827)) 

### 0.17.2 (2024-04-17)

#### Documentation

* Update comments on ServiceAccount email and scopes fields ([#25472](https://github.com/googleapis/google-cloud-ruby/issues/25472)) 

### 0.17.1 (2024-02-28)

#### Documentation

* Updated description of the Job uid field ([#25265](https://github.com/googleapis/google-cloud-ruby/issues/25265)) 

### 0.17.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24864](https://github.com/googleapis/google-cloud-ruby/issues/24864)) 

### 0.16.2 (2024-02-22)

#### Documentation

* refine proto comment for run_as_non_root ([#24837](https://github.com/googleapis/google-cloud-ruby/issues/24837)) 

### 0.16.1 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.16.0 (2024-01-25)

#### Features

* Container runnables support using image streaming 
* Support running a task group as non-root 
* Support tags in the allocation policy 
* Support the use_generic_task_monitored_resource cloud logging option 

### 0.15.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.15.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23773](https://github.com/googleapis/google-cloud-ruby/issues/23773)) 

### 0.14.0 (2023-12-04)

#### Features

* Added cloud_logging_option field to LogsPolicy ([#23565](https://github.com/googleapis/google-cloud-ruby/issues/23565)) 

### 0.13.1 (2023-11-02)

#### Documentation

* Update docs for default max parallel tasks per job ([#23490](https://github.com/googleapis/google-cloud-ruby/issues/23490)) 

### 0.13.0 (2023-10-23)

#### Features

* expose display_name to batch v1 API ([#23443](https://github.com/googleapis/google-cloud-ruby/issues/23443)) 

### 0.12.0 (2023-10-06)

#### Features

* add InstancePolicy.reservation field for restricting jobs to a specific reservation ([#23419](https://github.com/googleapis/google-cloud-ruby/issues/23419)) 

### 0.11.1 (2023-09-29)

#### Documentation

* update batch PD interface support ([#23379](https://github.com/googleapis/google-cloud-ruby/issues/23379)) 

### 0.11.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22917](https://github.com/googleapis/google-cloud-ruby/issues/22917)) 

### 0.10.5 (2023-09-07)

#### Documentation

* Update description for size_gb field in Disk ([#22875](https://github.com/googleapis/google-cloud-ruby/issues/22875)) 

### 0.10.4 (2023-09-04)

#### Documentation

* Clarify several type descriptions ([#22824](https://github.com/googleapis/google-cloud-ruby/issues/22824)) 

### 0.10.3 (2023-08-15)

#### Documentation

* Clarify Batch API proto doc about pubsub notifications ([#22749](https://github.com/googleapis/google-cloud-ruby/issues/22749)) 

### 0.10.2 (2023-08-03)

#### Documentation

* Add documentation for "order_by" field in list_jobs API ([#22672](https://github.com/googleapis/google-cloud-ruby/issues/22672)) 

### 0.10.1 (2023-07-10)

#### Documentation

* Add image shortcut example for Batch HPC CentOS Image ([#22476](https://github.com/googleapis/google-cloud-ruby/issues/22476)) 

### 0.10.0 (2023-06-16)

#### Features

* Add support for scheduling_policy ([#22399](https://github.com/googleapis/google-cloud-ruby/issues/22399)) 

### 0.9.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21672](https://github.com/googleapis/google-cloud-ruby/issues/21672)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.8.0 (2023-05-19)

#### Features

* support for placement policies 
* support labels for runnable 
* support UNEXECUTED state for TaskStatus 

### 0.7.0 (2023-03-08)

#### Features

* support new IAM policy handling 
* Support REST transport ([#20624](https://github.com/googleapis/google-cloud-ruby/issues/20624)) 
#### Documentation

* update comments 

### 0.6.0 (2023-02-13)

#### Features

* Support for InstancePolicy#boot_disk 
* Support for InstanceStatus#boot_disk ([#20123](https://github.com/googleapis/google-cloud-ruby/issues/20123)) 
* Support for ServiceAccount#scopes 

### 0.5.0 (2023-01-05)

#### Features

* Added support for secret and encrypted environment variables ([#19936](https://github.com/googleapis/google-cloud-ruby/issues/19936)) 
#### Documentation

* Minor fixes to reference documentation formatting ([#19898](https://github.com/googleapis/google-cloud-ruby/issues/19898)) 

### 0.4.3 (2022-12-15)

#### Documentation

* Document TaskSpec#environments field as deprecated ([#19880](https://github.com/googleapis/google-cloud-ruby/issues/19880)) 

### 0.4.2 (2022-12-09)

#### Documentation

* Minor updates to reference documentation ([#19462](https://github.com/googleapis/google-cloud-ruby/issues/19462)) 

### 0.4.1 (2022-11-10)

#### Documentation

* Fixed a few formatting strings ([#19401](https://github.com/googleapis/google-cloud-ruby/issues/19401)) 

### 0.4.0 (2022-10-19)

#### Features

* Enable install_gpu_drivers flag in v1 proto 
* Enable install_gpu_drivers flag in v1 proto ([#19290](https://github.com/googleapis/google-cloud-ruby/issues/19290)) 
#### Documentation

* Refine comments for deprecated proto fields 
* Refine GPU drivers installation proto description 
* Update the API comments about the device_name 

### 0.3.0 (2022-08-25)

#### Features

* Added disk interface field ([#19070](https://github.com/googleapis/google-cloud-ruby/issues/19070)) 
* Added the option to install GPU drivers 
* Support setting a timeout for a Runnable 
* Support setting environment variables 

### 0.2.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.1.0 (2022-06-22)

#### Features

* Initial generation of google-cloud-batch-v1
