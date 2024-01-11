# Release History

### 0.11.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23775](https://github.com/googleapis/google-cloud-ruby/issues/23775)) 

### 0.10.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22918](https://github.com/googleapis/google-cloud-ruby/issues/22918)) 

### 0.9.0 (2023-09-04)

#### Features

* Add enable_project_level_recipients for project owner budget emails 
* Add scope for project scope filter in list_budgets ([#22842](https://github.com/googleapis/google-cloud-ruby/issues/22842)) 

### 0.8.0 (2023-06-06)

#### Features

* Support for filtering by resource ancestors ([#22243](https://github.com/googleapis/google-cloud-ruby/issues/22243)) 
* Uses binary protobuf definitions for better forward compatibility ([#21672](https://github.com/googleapis/google-cloud-ruby/issues/21672)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.7.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.6.5 / 2022-02-15

#### Documentation

* Various improvements to reference documentation

### 0.6.4 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.6.3 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.6.2 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.6.1 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.6.0 / 2021-06-23

#### Features

* Added support for configurable budget time period

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.4.1 / 2021-02-16

#### Documentation

* Update a few field descriptions

### 0.4.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.3.2 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.3.1 / 2020-11-19

#### Documentation

* Reworded description of credit types filter

### 0.3.0 / 2020-11-02

#### Features

* Support the credit_types filter field

### 0.2.0 / 2020-09-16

#### Features

* Support an option to disable default budget alerts to IAM recipients

### 0.1.0 / 2020-09-10

Initial release.
