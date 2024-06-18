# Changelog

### 0.10.0 (2024-06-18)

#### Features

* Support for automatic feature management under MembershipSpec 
* Support for Config Sync admission webhook drift prevention 
* Support for Config Sync installation 
* Support for exporting metrics 
* Support for support OCI repo configuration 

### 0.9.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24871](https://github.com/googleapis/google-cloud-ruby/issues/24871)) 

### 0.8.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.8.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.8.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23780](https://github.com/googleapis/google-cloud-ruby/issues/23780)) 

### 0.7.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22920](https://github.com/googleapis/google-cloud-ruby/issues/22920)) 

### 0.6.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21675](https://github.com/googleapis/google-cloud-ruby/issues/21675)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.5.0 (2023-04-21)

#### Features

* Support monitoring configuration ([#21454](https://github.com/googleapis/google-cloud-ruby/issues/21454)) 
#### Documentation

* Improve documentation ([#21454](https://github.com/googleapis/google-cloud-ruby/issues/21454)) 

### 0.4.0 (2023-03-08)

#### Features

* Support REST transport ([#20627](https://github.com/googleapis/google-cloud-ruby/issues/20627)) 

### 0.3.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.2.0 (2022-04-15)

#### Features

* add KubernetesResource to membership endpoint

### 0.1.2 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.1.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.1.0 / 2021-09-23

#### Features

* Initial generation of google-cloud-gke_hub-v1
