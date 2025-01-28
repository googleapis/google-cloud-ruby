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

### 0.8.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 0.8.0 (2024-08-08)

#### Features

* additional field on the output that specified whether the deployment supports Physical Zone Separation. 
* Generate upload URL now supports for specifying the GCF generation that the generated upload url will be used for. 
* ListRuntimes response now includes deprecation and decommissioning dates. 
* optional field for binary authorization policy. 
* optional field for deploying a source from a GitHub repository. 
* optional field for specifying a revision on GetFunction. 
* optional field for specifying a service account to use for the build. This helps navigate the change of historical default on new projects. For more details, see https://cloud.google.com/build/docs/cloud-build-service-account-updates ([#26621](https://github.com/googleapis/google-cloud-ruby/issues/26621)) 
* optional fields for setting up automatic base image updates. 
#### Documentation

* Refined description in several fields. 

### 0.7.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24870](https://github.com/googleapis/google-cloud-ruby/issues/24870)) 

### 0.6.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.6.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.6.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23779](https://github.com/googleapis/google-cloud-ruby/issues/23779)) 

### 0.5.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22920](https://github.com/googleapis/google-cloud-ruby/issues/22920)) 

### 0.4.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.4.0 (2023-05-30)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21689](https://github.com/googleapis/google-cloud-ruby/issues/21689)) 
#### Documentation

* Marked several fields as preview 

### 0.3.0 (2023-03-23)

#### Features

* Add support for available_cpu field 
* Add support for kms_key_name ([#20918](https://github.com/googleapis/google-cloud-ruby/issues/20918)) 
* Add support for max_instance_request_concurrency field 
* Add support for security_level field 

### 0.2.0 (2023-03-08)

#### Features

* Support REST transport ([#20626](https://github.com/googleapis/google-cloud-ruby/issues/20626)) 

### 0.1.0 (2022-07-29)

#### Features

* Initial generation of google-cloud-functions-v2 ([#18922](https://github.com/googleapis/google-cloud-ruby/issues/18922))
