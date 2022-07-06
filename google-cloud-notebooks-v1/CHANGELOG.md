# Changelog

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
