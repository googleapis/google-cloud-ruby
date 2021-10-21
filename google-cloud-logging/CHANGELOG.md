# Release History

### 2.2.2 / 2021-10-21

#### Documentation

* Add documentation for quota_project Configuration attribute

### 2.2.1 / 2021-07-08

#### Documentation

* Update AUTHENTICATION.md in handwritten packages

### 2.2.0 / 2021-03-10

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 2.1.0 / 2020-09-16

#### Features

* quota_project can be set via library configuration

### 2.0.0 / 2020-07-21

This is a major update that removes the "low-level" client interface code, and
instead adds the new `google-cloud-logging-v2` gem as a dependency.
The new dependency is a rewritten low-level client, produced by a next-
generation client code generator, with improved performance and stability.

This change should have no effect on the high-level interface that most users
will use. The one exception is that the (mostly undocumented) `client_config`
argument, for adjusting low-level parameters such as RPC retry settings on
client objects, has been removed. If you need to adjust these parameters, use
the configuration interface in `google-cloud-logging-v2`.

Substantial changes have been made in the low-level interfaces, however. If you
are using the low-level classes under the `Google::Cloud::Logging::V2` module,
please review the docs for the new `google-cloud-logging-v2` gem. In
particular:

* Some classes have been renamed, notably the client class itself.
* The client constructor takes a configuration block instead of configuration
  keyword arguments.
* All RPC method arguments are now keyword arguments.

### 1.10.9 / 2020-06-17

#### Documentation

* Improved field descriptions in the low-level interface.

### 1.10.8 / 2020-06-12

#### Documentation

* Provide more details on low-level monitored resource data types

### 1.10.7 / 2020-05-28

#### Documentation

* Fix a few broken links

### 1.10.6 / 2020-05-19

#### Bug Fixes

* Adjusted some default timeout and retry settings

### 1.10.5 / 2020-05-05

#### Bug Fixes

* Prevent error when calling stop! on unused AsyncWriter

### 1.10.4 / 2020-04-20

#### Documentation

* Fix some broken links in the Project and Sink docs

### 1.10.3 / 2020-04-06

#### Documentation

* Fix some broken links in the low-level interface documentation.

### 1.10.2 / 2020-04-01

#### Bug Fixes

* Restore some path helpers in the low-level interface.

### 1.10.1 / 2020-03-19

#### Bug Fixes

* Restore billing, folder, and organization path helpers in low-level interface

### 1.10.0 / 2020-03-16

#### Features

* support separate project setting for quota/billing

#### Low-level interface updates

* Add LogBucket
* Add ConfigServiceV2Client#list_buckets
* Add ConfigServiceV2Client#get_bucket
* Add ConfigServiceV2Client#update_bucket
* Add LifecycleState enum
* Change name to positional param in ConfigServiceV2Client#get_cmek_settings
* Change name and cmek_settings to positional params in ConfigServiceV2Client#update_cmek_settings
* Remove billing, folder, and organization path helpers from ConfigServiceV2Client
* Remove LogEntry#metadata
* Remove previously deprecated project_ids from LoggingServiceV2Client#list_log_entries
* Remove log_path helpers from LoggingServiceV2Client
* Rename ConfigServiceV2Client#billing_path to #billing_account_path
* Rename LoggingServiceV2Client#billing_path to #billing_account_path
* Rename MetricsServiceV2Client#metric_path to #log_metric_path
* Update network configuration settings

### 1.9.5 / 2020-02-24

#### Documentation

* Fix doc links to Cmek methods in lower-level client

### 1.9.4 / 2020-01-23

#### Documentation

* Update copyright year

### 1.9.3 / 2019-12-20

#### Documentation

* Update description of MetricDescriptor#unit in lower-level API

### 1.9.2 / 2019-12-18

#### Bug Fixes

* Fix MonitorMixin usage on Ruby 2.7
  * Ruby 2.7 will error if new_cond is called before super().
  * Make the call to super() be the first call in initialize

#### Documentation

* Update docs for lower-level API call MetricDescriptorMetadata#unit

### 1.9.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 1.9.0 / 2019-10-29

This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform environments support automatic authentication

### 1.8.0 / 2019-10-03

#### Features

* Support additional fields of LogSink in the low-level interface
  * Add LogSink#create_time field
  * Add LogSink#update_time field
  * Add LogSink#bigquery_options field
  * Add BigQueryOptions type
  * Update documentation

### 1.7.0 / 2019-08-23

#### Features

* Support overriding of service endpoint

### 1.6.6 / 2019-07-31

* Fix max threads setting in thread pools
  * Thread pools once again limit the number of threads allocated.
* Update documentation links

### 1.6.5 / 2019-07-08

* Support overriding service host and port in the low-level interface.

### 1.6.4 / 2019-06-11

* Add documentation for MetricDescriptor#launch_stage and
  MonitoredResourceDescriptor#launch_stage.
* Deprecate MetricDescriptor:: MetricDescriptorMetadata#launch_stage
* Use VERSION constant in GAPIC client

### 1.6.3 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update generated documentation.
* Update generated code examples.
* Extract gRPC header values from request.

### 1.6.2 / 2019-02-13

* Fix bug (typo) in retrieving default on_error proc.

### 1.6.1 / 2019-02-07

* Update concurrent-ruby dependency

### 1.6.0 / 2019-01-22

* AsyncWriter buffer entries and make batch API calls
  * Update AsyncWriter to buffer log entries and batch API calls.
  * Maintain backwards compatibility with the previous AsyncWriter's public API,
    although the implementation is changed.
  * Back pressure is applied by limiting the number of queued API calls.
    Errors will now be raised when there are not enough resources.
  * Errors are reported using the AsyncWriter#on_error callback.
  * Pending log entries are sent before the process closes using at_exit.
  * Add Logging on_error configuration.
* Add default insert_id value for Entry
  * Add Entry.insert_id
  * Add default insert_id value for Entry
    An Entry object is assigned an insert_id when created so that if the
    Entry object gets persisted multiple times it would know its insert_id
    value and not attempt to generate a new one for each persist attempt.
    An Entry object will still be considered empty if the only value it has
    is the insert_id.
  * (This change does not use SecureRandom for performance reasons.)
* Add Logging trace_sampled
  * Add Entry#trace_sampled attribute
  * Add trace_sampled to Logger::RequestInfo
* Changes to Rails default Logger
  * Delay updating the Rails default logger until the first web request.
    * This will avoid issues with forking processes and gRPC resources.
    * This is accomplished by adding the on_init argument to middleware.
  * Add Railtie.set_default_logger
    * This method can be called post-fork to update the Rails default logger.  
* Make use of Credentials#project_id
  * Use Credentials#project_id
    If a project_id is not provided, use the value on the Credentials object.
    This value was added in googleauth 0.7.0.
  * Loosen googleauth dependency
    Allow for new releases up to 0.10.
    The googleauth devs have committed to maintaining the current API
    and will not make backwards compatible changes before 0.10.
* Direct logs for "/healthz" requests to the health check log.
* Update documentation.

### 1.5.7 / 2018-11-15

* Add Google::Logging::V2::LogEntry#trace_sampled.
* Update low-level documentation.

### 1.5.6 / 2018-10-03

* Use concurrent-ruby and ThreadLocalVar in Logger.
  * Remove Monitor and synchronize blocks.
  * Logger#thread_ids now only returns the current thread.

### 1.5.5 / 2018-09-20

* Make Logger thread-safe.
* Update Logging generated files.
  * Add Metric's MetricDescriptorMetadata.
* Update documentation.
  * Change documentation URL to googleapis GitHub org.
* Fix circular require warning.

### 1.5.4 / 2018-09-12

* Add missing documentation files to package.

### 1.5.3 / 2018-09-10

* Update documentation.

### 1.5.2 / 2018-08-21

* Update documentation.

### 1.5.1 / 2018-07-05

* Fix bug in List classes by propagating arguments needed for pagination calls.
* Fix issue when disabling Stackdriver components with Rails.env.production.
* Reduce string memory usage.
* Add documentation for enabling gRPC logging.

### 1.5.0 / 2018-02-27

* Use Google Cloud Shared Configuration.
* Deprecated Logging Sink attributes.

### 1.4.0 / 2017-12-19

* Update google-gax dependency to 1.0.

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
