# Release History

### 0.17.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23774](https://github.com/googleapis/google-cloud-ruby/issues/23774)) 

### 0.16.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22917](https://github.com/googleapis/google-cloud-ruby/issues/22917)) 

### 0.15.1 (2023-08-04)

#### Documentation

* Improve documentation format ([#22684](https://github.com/googleapis/google-cloud-ruby/issues/22684)) 

### 0.15.0 (2023-07-10)

#### Features

* add support for Salesforce connections, which are usable only by allowlisted partners ([#22490](https://github.com/googleapis/google-cloud-ruby/issues/22490)) 

### 0.14.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21672](https://github.com/googleapis/google-cloud-ruby/issues/21672)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.13.0 (2023-03-23)

#### Features

* Add support for SparkProperties ([#20924](https://github.com/googleapis/google-cloud-ruby/issues/20924)) 

### 0.12.0 (2023-03-08)

#### Features

* Support REST transport ([#20624](https://github.com/googleapis/google-cloud-ruby/issues/20624)) 

### 0.11.0 (2023-02-28)

#### Features

* Support for Serverless Analytics Service when reading from Cloud Spanner ([#20519](https://github.com/googleapis/google-cloud-ruby/issues/20519)) 
* Support for setting the Cloud Spanner database role 

### 0.10.0 (2022-08-03)

#### Features

* support Azure for connections 

### 0.9.0 (2022-07-28)

#### Features

* Added service_account_id output field for CloudSQL properties ([#18882](https://github.com/googleapis/google-cloud-ruby/issues/18882)) 

### 0.8.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.7.0 (2022-04-20)

#### Features

* Support for update masks when setting IAM policies

### 0.6.0 / 2022-03-08

#### Features

* Add Cloud Resource Connection Support

### 0.5.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.5.2 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.5.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.5.0 / 2021-07-14

#### Features

* Support spanner properties and AWS access role

### 0.4.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.4.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.4.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.3.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.2.1 / 2021-01-20

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.0 / 2020-10-14

#### Features

* add aws connection support

### 0.1.2 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.1 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.1.0 / 2020-06-25

Initial release.
