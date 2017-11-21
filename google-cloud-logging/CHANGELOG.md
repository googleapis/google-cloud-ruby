# Release History

### 1.3.2 / 2017-11-20

* Refresh GAPIC layer (low-level API) based on updates to Protobuf types.

### 1.3.1 / 2017-11-15

* Fix credentials verification bug in Railtie.

### 1.3.0 / 2017-11-14

* Add `Google::Cloud::Logging::Credentials` class.
* Rename constructor arguments to `project_id` and `credentials`.
  (The previous arguments `project` and `keyfile` are still supported.)
* Document `Google::Auth::Credentials` as `credentials` value.
* Add `partial_success` optional argument to `Project#write_entries`.
* Deprecate `HttpRequest#method`, use `HttpRequest#request_method` instead.
* Update generated low level GAPIC code.
* Updated `google-gax` (`grpc`, `google-protobuf`), `googleauth` dependencies.

### 1.2.3 / 2017-09-27

* Updated protobuf classes.
* Updated README.

### 1.2.2 / 2017-09-08

* Add `labels` configuration option to `Google::Cloud::Logging::Middleware` for Rails and other Rack-based framework integrations.

### 1.2.1 / 2017-07-11

* stackdriver-core 1.2.0 release

### 1.2.0 / 2017-07-11

* Update `labels` parameter in `Google::Cloud::Logging::Logger#initialize` to default to empty hash.
* Update `Google::Cloud::Logging::Logger` to support the following `ActiveSupport::Logger` methods: `:local_level`, `:local_level=`, `:silence`, `:silencer`, and `:unknown?`.
* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.
* Update gem spec homepage links.

### 1.1.0 / 2017-05-25

* Introduce new `Google::Cloud::Logging.configure` instrumentation configuration interface.
* Google::Cloud::Logger now sends extra trace context information in log entries.

### 1.0.1 / 2017-04-21

* Middleware constructor can be called without an explicit logger. This should make integration in non-Rails applications simpler.
* If Rails integration fails due to an auth error, the notice is now printed to STDOUT rather than STDERR, which should make it a bit less scary when displayed in Docker output.

### 1.0.0 / 2017-03-31

* Release 1.0
* Added `#trace` and `#source_location` to Entry
* Added listing of logs for the project
* Updated documentation
* Automatic retry on `UNAVAILABLE` errors

### 0.24.2 / 2017-03-03

* No public API changes.
* Update GRPC header value sent to the Logging API.

### 0.24.1 / 2017-03-01

* No public API changes.
* Update GRPC header value sent to the Logging API.
* Low level API adds new Protobuf types and GAPIC methods.

### 0.24.0 / 2017-02-21

* Fix GRPC retry bug
* The client_config data structure has replaced retry_codes/retry_codes_def with retry_codes
* Update GRPC/Protobuf/GAX dependencies

### 0.23.2 / 2016-12-27

* `Google::Cloud::Logging::Logger` depended on standard logger but didn't require it. Fixed.

### 0.23.1 / 2016-12-22

* Use the `stackdriver-core` gem to obtain Trace ID, for compatibility with the `google-cloud-trace` gem.
* `Google::Cloud::Logging::Logger` now understands all remaining standard Logger methods.
* Clean up `AsyncWriter` threads on VM exit, to prevent gRPC from crashing if it's still in the middle of a call.
* Support setting log name by path, and direct App Engine health checks to a separate log by default.
* Minor improvements to warning messages.

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
