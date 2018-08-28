# Release History

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
