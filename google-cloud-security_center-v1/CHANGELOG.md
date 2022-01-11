# Release History

### 0.11.1 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.11.0 / 2021-12-07

#### Features

* Support for mute configs
* Support for updating a finding with external system metadata

#### Documentation

* Formatting fixes in the reference docs

### 0.10.0 / 2021-11-11

#### Features

* Added fields display_name and resource type.

### 0.9.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.9.0 / 2021-10-18

#### Features

* Added vulnerability fields to findings

### 0.8.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.8.0 / 2021-07-29

#### Features

* Added class and indicator fields to security findings

### 0.7.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.7.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

#### Documentation

* Update currently supported Finding filter fields

### 0.7.0 / 2021-05-18

#### Features

* Support for folder information and asset canonical names

### 0.6.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.5.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.4.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.4.0 / 2020-12-15

#### Features

* Add field indicating severity of a finding

### 0.3.5 / 2020-09-03

#### Documentation

* Clarify Finding#event_time description

### 0.3.4 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.3.3 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.3.2 / 2020-07-16

#### Bug Fixes

* Update timeout settings

### 0.3.1 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.3.0 / 2020-06-12

#### Features

* Provide resource information in notifications.

### 0.2.2 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

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

### 0.1.0 / 2020-04-23

Initial release.
