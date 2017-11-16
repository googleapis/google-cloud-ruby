# Release History

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
