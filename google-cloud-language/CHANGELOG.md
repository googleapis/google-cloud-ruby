# Release History

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
