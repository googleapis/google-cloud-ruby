# Release History

### 1.7.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24877](https://github.com/googleapis/google-cloud-ruby/issues/24877)) 

### 1.6.0 (2024-01-15)

#### Features

* Support for universe_domain ([#24267](https://github.com/googleapis/google-cloud-ruby/issues/24267)) 

### 1.5.0 (2023-02-28)

#### Features

* Support REST transport ([#20523](https://github.com/googleapis/google-cloud-ruby/issues/20523)) 

### 1.4.0 (2022-07-08)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 1.3.0 (2022-05-13)

#### Features

* Support for the Adaptation API

### 1.2.3 / 2022-01-12

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

### 1.1.3 / 2021-02-03

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

### 1.0.0 / 2020-05-05

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.
* An expanded, standardized streaming interface.

See the [MIGRATING](https://googleapis.dev/ruby/google-cloud-speech/latest/file.MIGRATING.html) file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.41.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.40.2 / 2020-01-22

#### Documentation

* Update copyright year

### 0.40.1 / 2019-12-19

#### Bug Fixes

* Fix MonitorMixin usage on Ruby 2.7
  * Ruby 2.7 will error if new_cond is called before super().
  * Make the call to super() be the first call in initialize when possible.

#### Performance Improvements

* Update network configuration

### 0.40.0 / 2019-11-19

#### Features

* Add WordInfo#speaker_tag

#### Documentation

* Update bucket name in code examples

### 0.39.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.39.0 / 2019-10-29

This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.38.0 / 2019-10-03

#### Features

* Add Speaker Diarization
  * Add RecognitionConfig#diarization_config
  * Add SpeakerDiarizationConfig

#### Documentation

* Update service name to "Speech-to-Text" and make minor formatting changes

### 0.37.0 / 2019-08-22

#### Features

* Add RecognitionConfig#diarization_config
* Add SpeakerDiarizationConfig

#### Documentation

* Update documentation

### 0.36.0 / 2019-07-08

* Update documentation.
* Support overriding service host and port.

### 0.35.0 / 2019-06-11

* Update documentation for SpeechContext phrases
* Add RecognitionConfig#metadata (RecognitionMetadata)
* Add StreamingRecognitionResult#result_end_time
* Add StreamingRecognitionResult#language_code
* Add VERSION constant

### 0.34.1 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update documentation for common types.
* Update generated documentation.

### 0.34.0 / 2019-02-01

* Add RecognitionConfig#audio_channel_count attribute

### 0.33.0 / 2019-01-24

* Add the following attributes to the Google::Cloud::Speech::V1 namespace:
  * RecognitionConfig#enable_separate_recognition_per_channel
  * StreamingRecognitionResult#channel_tag
  * SpeechRecognitionResult#channel_tag
* Update documentation.

### 0.32.0 / 2018-11-15

* Add StreamingRecognitionResult#result_end_time value.
* Update documentation.
* Update network configuration.

### 0.31.1 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.31.0 / 2018-09-10

* Add get_operation to retrieve long running operation resource.
* Update documentation.

### 0.30.1 / 2018-08-21

* Update documentation.

### 0.30.0 / 2018-06-21

* The 0.30.0 release introduced breaking changes relative to the previous
  release, 0.29.0. For more details and instructions to migrate your code,
  please visit the migration guide:

  https://cloud.google.com/speech-to-text/docs/ruby-client-migration
* Add V1pbeta1 API

### 0.29.0 / 2018-02-27

* Support Shared Configuration.

### 0.28.0 / 2017-12-19

* Update Low Level API code
  * Remove deprecated constructor arguments.
  * Update documentation.
* Update google-gax dependency to 1.0.

### 0.27.0 / 2017-11-14

* Add `Google::Cloud::Speech::Credentials` class.
* Rename constructor arguments to `project_id` and `credentials`.
  (The previous arguments `project` and `keyfile` are still supported.)
* Document `Google::Auth::Credentials` as `credentials` value.
* Update generated low level GAPIC code.
* Updated `google-gax` (`grpc`, `google-protobuf`), `googleauth` dependencies.

### 0.26.2 / 2017-08-29

* Correct stream example code

### 0.26.1 / 2017-08-01

* Update documentation.

### 0.26.0 / 2017-07-28

* Add words argument for recognition, Result#words, and Result::Word

### 0.25.0 / 2017-07-11

* Replace the `encoding` type `:raw` with `:linear16` in code, tests, and examples.
* Update initialization to raise a better error if project ID is not specified.
* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.

### 0.24.0 / 2017-04-05

* Upgrade to V1 API, including the following changes:
	* Support `OGG_OPUS` and `SPEEX_WITH_HEADER_BYTE` encodings
	* The `language` argument is now mandatory on all recognition methods
	* `#recognize_job` has been renamed `#process`, aliased as `#long_running_recognize` and `#recognize_job`
	* `#stream` has been aliased as `#stream_recognize`
	* `Stream` added `#wait_until_complete!` method, which blocks until stream is complete
	* `Stream` removed `#speech_start` and `#speech_end` callback methods
	* `Stream` now calls `#complete` callback method when stream ends, not when `END_OF_AUDIO` event is received (the `END_OF_AUDIO` event was removed in V1)
	* `Job` has been renamed `Operation`
	* `Operation` added `id` attribute, can be retrieved by `id`
* Add documentation for Low Level API

### 0.23.0 / 2017-03-31

* Updated documentation
* Automatic retry on `UNAVAILABLE` errors

### 0.22.2 / 2017-03-03

* No public API changes.
* Update GRPC header value sent to the Speech API.

### 0.22.1 / 2017-03-01

* No public API changes.
* Update GRPC header value sent to the Speech API.

### 0.22.0 / 2017-02-21

* Fix GRPC retry bug
* The client_config data structure has replaced retry_codes/retry_codes_def with retry_codes
* Update GRPC/Protobuf/GAX dependencies
* Update links in documentation

### 0.21.1 / 2016-11/19

* Fix issue with language as a Symbol (frankyn)

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Speech.new
* New constructor argument client_config
* Streaming support added

### 0.20.0 / 2016-09-30

Initial implementation of the Google Cloud Speech API Ruby client.
