# Release History

### 0.22.0 / 2017-02-21

* Fix GRPC retry bug
* The client_config data structure has replaced retry_codes/retry_codes_def with retry_codes
* Update GRPC/Protobuf/GAX dependencies
* Updates to code examples in documentation

### 0.21.1 / 2016-10-27

* Fix outdated requires (Ricowere)

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Vision.new
* New constructor argument client_config

### 0.20.2 / 2016-09-06

* Fix for using GCS URLs. (erikaxel)

### 0.20.1 / 2016-09-02

* Fix for timeout on uploads.

### 0.20.0 / 2016-08-26

This gem contains the Google Cloud Vision service implementation for the `google-cloud` gem. The `google-cloud` gem replaces the old `gcloud` gem. Legacy code can continue to use the `gcloud` gem.

* Namespace is now `Google::Cloud`
* The `google-cloud` gem is now an umbrella package for individual gems
