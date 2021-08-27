# Release History

### 0.11.0 / 2021-08-23

#### Features

* Support for transcript normalization

### 0.10.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.10.0 / 2021-07-29

#### Features

* Provide information on how much billed time an operation consumed

### 0.9.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.9.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.9.0 / 2021-05-06

#### Features

* Add webm opus support

### 0.8.0 / 2021-04-26

#### Features

* Support for spoken punctuation and spoken emojis

### 0.7.0 / 2021-03-25

#### Features

* Support output transcript to GCS for long_running_recognize
* Support output transcript to GCS for LongRunningRecognize

### 0.6.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.5.0 / 2021-02-22

#### Features

* Support for model adaptation

### 0.4.0 / 2021-02-03

#### Features

* Use self-signed JWT credentials when possible

### 0.3.6 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.3.5 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.3.4 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.3.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.3.2 / 2020-06-05

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

### 0.3.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file
* The long-running operations client honors the quota_project config

### 0.3.0 / 2020-05-21

#### Features

* The quota_project can be set via configuration

### 0.2.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.2.0 / 2020-04-22

#### Features

* Support for speech adaptation configuration.

#### Bug Fixes

* Operations client honors its main client's custom endpoint.

### 0.1.2 / 2020-04-13

#### Documentation

* Various documentation and other updates.
  * Expanded the readme to include quickstart and logging information.
  * Added documentation for package and service modules.
  * Fixed and expanded documentation for the two method calling conventions.
  * Fixed some circular require warnings.

### 0.1.1 / 2020-04-01

#### Documentation

* Update documentation for core proto types.

### 0.1.0 / 2020-03-25

Initial release.
