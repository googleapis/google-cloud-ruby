# Release History

### 1.6.0 (2024-01-15)

#### Features

* Support for universe_domain ([#24268](https://github.com/googleapis/google-cloud-ruby/issues/24268)) 

### 1.5.0 (2023-02-28)

#### Features

* Support REST transport ([#20523](https://github.com/googleapis/google-cloud-ruby/issues/20523)) 

### 1.4.0 (2022-12-14)

#### Features

* Added support for the TextToSpeechLongAudioSynthesize client ([#19834](https://github.com/googleapis/google-cloud-ruby/issues/19834)) 

### 1.3.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 1.2.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.2.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.2.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.2.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.1.3 / 2021-02-02

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.1.2 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.1.1 / 2020-05-26

#### Documentation

* Cover exception changes in the migration guide

### 1.1.0 / 2020-05-20

#### Features

* The endpoint, scope, and quota_project can be set via configuration

### 1.0.0 / 2020-05-06

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* More consistent spelling of module names.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.7.0 / 2020-04-10

#### Features

* Move data type classes from Texttospeech to TextToSpeech.
  * Note: Texttospeech was left as an alias, so older code should still work.

### 0.6.1 / 2020-04-01

#### Documentation

* Remove broken troubleshooting link from auth guide.

### 0.6.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.5.2 / 2020-01-23

#### Documentation

* Update copyright year

### 0.5.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.5.0 / 2019-10-29

This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.4.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.4.0 / 2019-07-08

* Update code example in READMEs.
* Support overriding service host and port.

### 0.3.1 / 2019-06-11

* Add VERSION constant

### 0.3.0 / 2019-04-29

* Add V1beta1 client.
* Add AUTHENTICATION.md guide.

### 0.2.0 / 2019-02-01

* Add AudioConfig#effects_profile_id.
* Updated code examples.

### 0.1.3 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.1.2 / 2018-09-10

* Update documentation.

### 0.1.1 / 2018-08-21

* Update documentation.

### 0.1.0 / 2018-07-09

* Initial release
