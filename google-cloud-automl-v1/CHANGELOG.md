# Release History

### 0.4.4 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.4.3 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.4.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.4.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.4.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.3.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.2.8 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.7 / 2020-12-08

#### Bug Fixes

* Set version constants in the correct modules

### 0.2.6 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.2.5 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.2.4 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.2.3 / 2020-06-08

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

#### Documentation

* Fix additional broken/misformatted links

### 0.2.2 / 2020-05-28

#### Documentation

* Fix a few broken links

### 0.2.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file
* The long-running operations client honors the quota_project config

### 0.2.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.1.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.
* Clean up formatting of a few documentation sections.

### 0.1.0 / 2020-04-24

Initial release.
