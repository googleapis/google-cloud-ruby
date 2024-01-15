# Release History

### 1.6.0 (2024-01-15)

#### Features

* Support for universe_domain ([#24262](https://github.com/googleapis/google-cloud-ruby/issues/24262)) 

### 1.5.0 (2023-02-28)

#### Features

* Support REST transport ([#20523](https://github.com/googleapis/google-cloud-ruby/issues/20523)) 

### 1.4.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 1.3.4 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.3.3 / 2021-09-28

* Update versions of gapic clients

### 1.3.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.3.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.3.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.2.3 / 2021-02-03

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.2.2 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.2.1 / 2020-05-25

#### Documentation

* Cover exception changes in the migration guide

### 1.2.0 / 2020-05-20

#### Features

* The endpoint, scope, and quota_project can be set via configuration

### 1.1.1 / 2020-05-05

#### Bug Fixes

* Eliminated a circular require warning.

#### Documentation

* Updated the sample timeouts in the migration guide to reflect seconds

### 1.1.0 / 2020-04-13

#### Features

* Let Bundler.require load the gem without an extra explicit require call.

### 1.0.0 / 2020-03-24

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.

See the MIGRATING file in the documentation for more detailed information and instructions for migrating from earlier versions.

### 0.36.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.35.3 / 2020-01-23

#### Documentation

* Update copyright year

### 0.35.2 / 2019-12-19

#### Documentation

* Update spelling of "part-of-speech"

### 0.35.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.35.0 / 2019-10-29

This release require Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.34.0 / 2019-10-03

#### Features

* Add support for more entity types
  * Add Entity::Type::PHONE_NUMBER
  * Add Entity::Type::ADDRESS
  * Add Entity::Type::DATE
  * Add Entity::Type::NUMBER
  * Add Entity::Type::PRICE
  * Update documentation

### 0.33.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.33.0 / 2019-07-08

* Support overriding service host and port.

### 0.32.2 / 2019-06-11

* Add VERSION constant

### 0.32.1 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update generated documentation.

### 0.32.0 / 2019-03-27

* Update documentation
* Add the following Entity types:
  * PHONE_NUMBER
  * ADDRESS
  * DATE
  * NUMBER
  * PRICE

### 0.31.2 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.31.1 / 2018-09-10

* Update documentation.

### 0.31.0 / 2018-08-21

* Move Credentials location:
  * Add Google::Cloud::Language::V1::Credentials
  * Remove Google::Cloud::Language::Credentials
* Update dependencies.
* Update documentation.

### 0.30.0 / 2017-12-19

* Update generated files and documentation.

### 0.29.0 / 2017-12-19

* Documentation updates.
* Update google-gax dependency to 1.0.

### 0.28.1 / 2017-11-15

* Fix Credentials environment variable names.

### 0.28.0 / 2017-11-14

#### BREAKING CHANGE

This release introduces breaking changes relative to the previous release.
For more details and instructions to migrate your code, please visit the
[migration guide](https://cloud.google.com/natural-language/docs/ruby-client-migration).

* Replace hand-written client with code generated client.
* Updated `google-gax` (`grpc`, `google-protobuf`), `googleauth` dependencies.

### 0.27.1 / 2017-08-30

* Update GAPIC V1Beta2 API.

### 0.27.0 / 2017-07-11

* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.
* Update initialization to raise a better error if project ID is not specified.
* Add GAPIC V1Beta2 API documentation.
* Update gem spec homepage links.

### 0.26.2 / 2017-04-06

* Update documentation.

### 0.26.1 / 2017-04-06

* Fix error due to missing require.
* Add v1beta2 Low level API.

### 0.26.0 / 2017-03-31

* Automatic retry on `UNAVAILABLE` errors

### 0.25.0 / 2017-03-03

* Removal of `encoding` method argument, encoding now calculated from system settings.
* Updated documentation and code examples.
* Update GRPC header value sent to the Natural Language API.

### 0.24.0 / 2017-02-21

* Fix GRPC retry bug
* The client_config data structure has replaced retry_codes/retry_codes_def with retry_codes
* Update GRPC/Protobuf/GAX dependencies

### 0.23.0 / 2017-01-27

* Change class names in low-level API (GAPIC)

### 0.22.0 / 2016-11-14

* Upgrade to V1
* Add Sentence and Entity::Mention objects
* Add Sentence-level Sentiment
* Updated PartOfSpeech structure
* Add `score` and `sentences` attributes to Sentiment
* Remove `polarity` attribute from Sentiment
* Add `mid` attribute to Entity

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Language.new

### 0.20.2 / 2016-09-02

* Fix an issue with the GRPC client and forked sub-processes

### 0.20.1 / 2016-08-29

* Fix documentation.

### 0.20.0 / 2016-08-26

This gem contains the Google Cloud Natural Language service implementation for the `google-cloud` gem. This is the first release.
