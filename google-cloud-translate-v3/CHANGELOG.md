# Release History

### 0.11.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23787](https://github.com/googleapis/google-cloud-ruby/issues/23787)) 

### 0.10.0 (2024-01-03)

#### Features

* Add Adaptive MT API ([#23668](https://github.com/googleapis/google-cloud-ruby/issues/23668)) 

### 0.9.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22925](https://github.com/googleapis/google-cloud-ruby/issues/22925)) 

### 0.8.0 (2023-08-15)

#### Features

* Added shadow removal and rotation correction options to Document Translation and Batch Document Translation API ([#22748](https://github.com/googleapis/google-cloud-ruby/issues/22748)) 

### 0.7.3 (2023-08-03)

#### Documentation

* Format documentation ([#22667](https://github.com/googleapis/google-cloud-ruby/issues/22667)) 

### 0.7.2 (2023-07-28)

#### Documentation

* Minor formatting ([#22635](https://github.com/googleapis/google-cloud-ruby/issues/22635)) 

### 0.7.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.7.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21679](https://github.com/googleapis/google-cloud-ruby/issues/21679)) 

### 0.6.0 (2023-02-22)

#### Features

* Added display_name field to Glossary 
* Support for removing the shadow text for native PDF translation 
* Support translating only native PDF pages 
* Support user-customized attribution flag ([#20490](https://github.com/googleapis/google-cloud-ruby/issues/20490)) 

### 0.5.2 (2023-02-17)

#### Bug Fixes

* Fixed routing headers sent with long-running operation calls ([#20453](https://github.com/googleapis/google-cloud-ruby/issues/20453)) 

### 0.5.1 (2022-12-09)

#### Documentation

* Minor fix to reference documentation formatting ([#19831](https://github.com/googleapis/google-cloud-ruby/issues/19831)) 

### 0.5.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.4.2 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.4.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.4.0 / 2021-08-31

#### Features

* Support translate_document and batch_translate_document RPCs

### 0.3.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.3.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.3.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.3.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.2.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.1.5 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.1.4 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.3 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

#### Documentation

* Fix some field documentation formatting.

### 0.1.2 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.1.1 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.1.0 / 2020-05-25

Initial release
