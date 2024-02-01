# Changelog

### 0.8.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.8.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.8.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23784](https://github.com/googleapis/google-cloud-ruby/issues/23784)) 

### 0.7.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22923](https://github.com/googleapis/google-cloud-ruby/issues/22923)) 

### 0.6.2 (2023-08-04)

#### Documentation

* Improve documentation format ([#22684](https://github.com/googleapis/google-cloud-ruby/issues/22684)) 

### 0.6.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.6.0 (2023-06-01)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21677](https://github.com/googleapis/google-cloud-ruby/issues/21677)) 

### 0.5.1 (2023-05-04)

#### Documentation

* Fix some documentation content and formatting ([#21536](https://github.com/googleapis/google-cloud-ruby/issues/21536)) 
* Replaced poorly formatted tables with lists. 

### 0.5.0 (2023-04-21)

#### Features

* Support `GetNamespacedTagKey` and `GetNamespacedTagValue` APIs ([#21452](https://github.com/googleapis/google-cloud-ruby/issues/21452)) 
* Support `ListEffectiveTags` API ([#21452](https://github.com/googleapis/google-cloud-ruby/issues/21452)) 
* Support `TagHold` APIs ([#21452](https://github.com/googleapis/google-cloud-ruby/issues/21452)) 

### 0.4.0 (2023-03-08)

#### Features

* Support REST transport ([#20628](https://github.com/googleapis/google-cloud-ruby/issues/20628)) 

### 0.3.0 (2022-07-07)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.2.0 (2022-04-20)

#### Features

* Support for update masks when setting IAM policies

### 0.1.3 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.1.2 / 2021-12-07

#### Documentation

* Improved reference documentation formatting

### 0.1.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation
* Reformat some tables as plain text

### 0.1.0 / 2021-08-19

#### Features

* Initial generation of google-cloud-resource_manager-v3
