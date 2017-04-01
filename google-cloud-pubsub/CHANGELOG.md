# Release History

### 0.24.0 / 2017-03-31

* Updated documentation
* Updated retry configuration for pull requests
* Automatic retry on `UNAVAILABLE` errors

### 0.23.2 / 2017-03-03

* No public API changes.
* Update GRPC header value sent to the Pub/Sub API.

### 0.23.1 / 2017-03-01

* No public API changes.
* Update GRPC header value sent to the Pub/Sub API.
* Low level API adds new Protobuf types and GAPIC methods.

### 0.23.0 / 2017-02-21

* Add emulator_host parameter
* Fix GRPC retry bug
* The client_config data structure has replaced retry_codes/retry_codes_def with retry_codes
* Update GRPC/Protobuf/GAX dependencies

### 0.22.0 / 2017-01-26

* Change class names in low-level API (GAPIC)
* Change method parameters in low-level API (GAPIC)
* Add LICENSE to package.

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Pubsub.new
* New constructor argument client_config

### 0.20.1 / 2016-09-02

* Fix an issue with the GRPC client and forked sub-processes

### 0.20.0 / 2016-08-26

This gem contains the Google Cloud Pub/Sub service implementation for the `google-cloud` gem. The `google-cloud` gem replaces the old `gcloud` gem. Legacy code can continue to use the `gcloud` gem.

* Namespace is now `Google::Cloud`
* The `google-cloud` gem is now an umbrella package for individual gems
