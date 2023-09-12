# Changelog

### 0.7.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22922](https://github.com/googleapis/google-cloud-ruby/issues/22922)) 

### 0.6.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.6.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21676](https://github.com/googleapis/google-cloud-ruby/issues/21676)) 

### 0.5.0 (2023-03-08)

#### Features

* Support REST transport ([#20627](https://github.com/googleapis/google-cloud-ruby/issues/20627)) 

### 0.4.2 (2023-01-05)

#### Documentation

* Minor formatting fixes to reference documentation ([#19938](https://github.com/googleapis/google-cloud-ruby/issues/19938)) 

### 0.4.1 (2022-12-09)

#### Documentation

* Formatting fixes for reference documentation ([#19478](https://github.com/googleapis/google-cloud-ruby/issues/19478)) 

### 0.4.0 (2022-11-17)

#### Features

* add Instance.reservation_affinity, nic_type, can_ip_forward 
* add IsInstanceUpgradeableResponse.upgrade_image 
* added Location and IAM methods 
* Support UpdateRuntime, UpgradeRuntime, DiagnoseRuntime, DiagnoseInstance  

### 0.3.0 (2022-07-06)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.2.1 (2022-05-05)

#### Documentation

* Fix the documented format for the VMImage#project field

### 0.2.0 (2022-04-21)

#### Features

* add refresh_runtime_token_internal and update_instance_metadata_items apis
* add request_id to client’s create_runtime, delete_runtime, start runtime, stop_runtime, switch_runtime and reset_runtime
* add reserved_ip_range and boot_image to VirtualMachineConfig
* add tensorboard_path to notebook_service
* add vertex_ai_parameters to execution
* update event and event type enum
* update instance to add creator and can_ip_forward
* update runtime type and add upgrade type to instance upgrade

### 0.1.0 / 2022-04-01

#### Features

* Initial generation of google-cloud-notebooks-v1
