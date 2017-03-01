# Release History

### 0.24.1 / 2017-03-01

* No public API changes.
* Update GRPC header value sent to the Datastore API.

### 0.24.0 / 2017-02-21

* Add emulator_host parameter
* Fix GRPC retry bug
* The client_config data structure has replaced retry_codes/retry_codes_def with retry_codes
* Update GRPC/Protobuf/GAX dependencies

### 0.23.0 / 2016-12-8

* Many documentation improvements
* Add documentation for Low Level API

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Datastore.new
* New constructor argument client_config
* Entity properties can now be accessed with symbols as well as strings

### 0.20.1 / 2016-09-02

* Fix an issue with the GRPC client and forked sub-processes

### 0.20.0 / 2016-08-26

This gem contains the Google Cloud Datastore service implementation for the `google-cloud` gem. The `google-cloud` gem replaces the old `gcloud` gem. Legacy code can continue to use the `gcloud` gem.

* Namespace is now `Google::Cloud`
* The `google-cloud` gem is now an umbrella package for individual gems

#### Changes

* Upgraded to V1
* Fix issue with embedded entities (@Dragor2)
