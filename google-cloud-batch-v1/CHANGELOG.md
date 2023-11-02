# Changelog

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
