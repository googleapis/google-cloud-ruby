# Release History

### 0.20.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.20.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23786](https://github.com/googleapis/google-cloud-ruby/issues/23786)) 

### 0.19.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22924](https://github.com/googleapis/google-cloud-ruby/issues/22924)) 

### 0.18.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.18.0 (2023-05-31)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21678](https://github.com/googleapis/google-cloud-ruby/issues/21678)) 

### 0.17.1 (2023-03-23)

#### Documentation

* Fix the resource name format for CreatePhraseSetRequest ([#20949](https://github.com/googleapis/google-cloud-ruby/issues/20949)) 

### 0.17.0 (2023-02-28)

#### Features

* Support for voice activity events during streaming recognition ([#20520](https://github.com/googleapis/google-cloud-ruby/issues/20520)) 

### 0.16.0 (2023-02-23)

#### Features

* Added support for REST transport ([#20498](https://github.com/googleapis/google-cloud-ruby/issues/20498)) 

### 0.15.3 (2023-02-17)

#### Bug Fixes

* Fixed routing headers sent with long-running operation calls ([#20452](https://github.com/googleapis/google-cloud-ruby/issues/20452)) 

### 0.15.2 (2023-02-09)

#### Documentation

* Clarify boost usage ([#20106](https://github.com/googleapis/google-cloud-ruby/issues/20106)) 

### 0.15.1 (2023-01-26)

#### Documentation

* Clarify boost usage in Phrase and PhraseSet ([#20066](https://github.com/googleapis/google-cloud-ruby/issues/20066)) 

### 0.15.0 (2023-01-05)

#### Features

* Support ABNF grammars in speech adaptation ([#19953](https://github.com/googleapis/google-cloud-ruby/issues/19953)) 

### 0.14.0 (2022-12-09)

#### Features

* Responses now provide information on adaptation behavior ([#19486](https://github.com/googleapis/google-cloud-ruby/issues/19486)) 

### 0.13.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.12.4 (2022-05-12)

#### Documentation

* Various updates to reference documentation

### 0.12.3 (2022-05-03)

#### Documentation

* Document the latest_long and latest_short recognition models

### 0.12.2 (2022-04-20)

#### Documentation

* Fix broken links in reference documentation

### 0.12.1 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.12.0 / 2021-12-07

#### Features

* Speech recognition results include the end time relative to the start of the audio clip

### 0.11.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

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
