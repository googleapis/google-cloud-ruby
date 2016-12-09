# Release History

### 0.23.0 / 2016-12-8

* Add `resources` method argument to `Project#entries`
* Deprecate `projects` method argument from `Project#entries`
* Add `start_at`, `end_at`, and `writer_identity` attributes to `Sink`
* Add `start_at`, `end_at`, and `unique_writer_identity` parameters to `Project#create_sink`
* Add `unique_writer_identity` parameter to `Sink#save`
* Many documentation improvements
* Add documentation for Low Level API

### 0.21.2 / 2016-11-15

* Fix issue with uninitialized VERSION (remi)

### 0.21.1 / 2016-11-4

* Upgraded Google::Cloud::Logging::Railtie to use AsyncWriter
* Added Rails configuration for custom monitored resource

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Logging.new
* New constructor argument client_config
* Logger is now asynchronous
* AsyncWriter added
* Rails and Rack integration added

### 0.20.1 / 2016-09-02

* Fix an issue with the GRPC client and forked sub-processes

### 0.20.0 / 2016-08-26

This gem contains the Stackdriver Logging service implementation for the `google-cloud` gem. The `google-cloud` gem replaces the old `gcloud` gem. Legacy code can continue to use the `gcloud` gem.

* Namespace is now `Google::Cloud`
* The `google-cloud` gem is now an umbrella package for individual gems
