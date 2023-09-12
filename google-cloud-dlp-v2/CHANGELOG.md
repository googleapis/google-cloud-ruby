# Release History

### 0.18.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22919](https://github.com/googleapis/google-cloud-ruby/issues/22919)) 

### 0.17.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21674](https://github.com/googleapis/google-cloud-ruby/issues/21674)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.16.0 (2023-03-08)

#### Features

* Support REST transport ([#20626](https://github.com/googleapis/google-cloud-ruby/issues/20626)) 

### 0.15.0 (2023-02-17)

#### Features

* Include the location mixin client ([#20455](https://github.com/googleapis/google-cloud-ruby/issues/20455)) 

### 0.14.0 (2022-11-11)

#### Features

* support ExcludeByHotword and add :NEW_ZEALAND to LocationCategory 

### 0.13.1 (2022-10-03)

#### Documentation

* Deprecate InfoTypeSummary#estimated_prevalence ([#19237](https://github.com/googleapis/google-cloud-ruby/issues/19237)) 

### 0.13.0 (2022-09-07)

#### Features

* add support for deidentify 
* add VersionDescription to InfoTypeDescription 
* move sensitivityscore to storage 
#### Documentation

* update auth doc with application-default 

### 0.12.0 (2022-07-19)

#### Features

* Support for InfoType categories ([#18828](https://github.com/googleapis/google-cloud-ruby/issues/18828)) 

### 0.11.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.10.0 / 2022-04-01

#### Features

* Add data types for DataProfile PubSub messages

### 0.9.0 / 2022-03-29

#### Features

* Support for PowerPoint and Excel document types

### 0.8.1 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.8.0 / 2021-12-07

#### Features

* Deidentify supports replacement dictionaries
* Support setting the type of job when listing triggers
* Findings include a unique finding ID
* Support for InfoType versioning
* Support for BigQuery inspect template inclusion lists

### 0.7.4 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.7.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.7.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.7.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.7.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.6.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.5.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.5.0 / 2020-10-14

#### Features

* Retrieve the job config for risk analysis jobs

### 0.4.4 / 2020-09-18

#### Documentation

* Fixed a number of broken links and a few malformed regular expressions

### 0.4.3 / 2020-09-10

#### Documentation

* Expand descriptions of a number of fields, particulary parent resources

### 0.4.2 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.4.1 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.4.0 / 2020-07-10

#### Features

* Support CSV and TSV storage file types.

### 0.3.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.3.2 / 2020-06-08

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

#### Documentation

* Fixed broken links in the reference documentation

### 0.3.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file

### 0.3.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.2.0 / 2020-05-14

#### Features

* **Breaking Change:** Content parent paths include their location, rather than location being a separate argument.
* Support MetadataLocation and several additional file types.

### 0.1.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.1.0 / 2020-04-23

Initial release.
