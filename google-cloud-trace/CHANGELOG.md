# Release History

### 0.34.0 / 2019-02-07

* Update `AsyncReporter` to buffer traces and batch API calls.
  * Back pressure is applied by limiting the number of queued API calls.
  * Errors will now be raised when there are not enough resources.
  * Errors are reported using the `AsyncReporter#on_error` callback.
  * Pending traces are sent before the process closes using `at_exit`.
* Improve middleware error handling
  * Add the `on_error` Proc to the Trace configuration that is called
    when an error is encountered in the middleware. This allows users
    to handle the errors proactively, instead of scanning logs.
* Make use of `Credentials#project_id`
  * Use `Credentials#project_id`
    If a `project_id` is not provided, use the value on the Credentials object.
    This value was added in googleauth 0.7.0.
  * Loosen googleauth dependency
    Allow for new releases up to 0.10.
    The googleauth devs have committed to maintaining the current API
    and will not make backwards compatible changes before 0.10.

### 0.33.6 / 2018-11-15

* Update network configuration.

### 0.33.5 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.
* Fix circular require warning.

### 0.33.4 / 2018-09-12

* Add missing documentation files to package.

### 0.33.3 / 2018-09-10

* Update documentation.

### 0.33.2 / 2018-08-21

* Update documentation.

### 0.33.1 / 2018-07-05

* Fix issue when disabling Stackdriver components with Rails.env.production.
* Add /healthz to the ignored requests. (diegodurs)
* Add documentation for enabling gRPC logging.

### 0.33.0 / 2018-05-01

* Fix labels in Trace. (tareksamni)

### 0.31.0 / 2018-02-27

* Use Google Cloud Shared Configuration.
* Update authentication documentation.

### 0.30.0 / 2017-12-26

* Add `Google::Cloud::Trace::V2::TraceServiceClient` class.

### 0.29.0 / 2017-12-19

* Update google-gax dependency to 1.0.

### 0.28.1 / 2017-11-15

* Fix credentials verification bug in Railtie.

### 0.28.0 / 2017-11-14

* Add `Google::Cloud::Trace::Credentials` class.
* Rename constructor arguments to `project_id` and `credentials`.
  (The previous arguments `project` and `keyfile` are still supported.)
* Document `Google::Auth::Credentials` as `credentials` value.
* Update generated low level GAPIC code.
* Updated `google-gax` (`grpc`, `google-protobuf`), `googleauth` dependencies.

### 0.27.2 / 2017-09-20

* Fix the bug where `Google::Cloud::Trace::Middleware` wasn't using the shared `project_id` parameter.

### 0.27.1 / 2017-09-08

* Print captured exception from asynchronous worker thread.

### 0.27.0 / 2017-08-07

* Add instrumentation to collect outbound GRPC requests information.

### 0.26.1 / 2017-07-11

* stackdriver-core 1.2.0 release

### 0.26.0 / 2017-07-11

* Add Faraday Middleware to help collect outbound RPC information.
* Update `Google::Cloud::Trace::Middleware` and `Google::Cloud::Trace::Railtie` to submit trace spans asynchronously by default.
* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.

### 0.25.0 / 2017-05-25

* Introduce new `Google::Cloud::Trace.configure` instrumentation configuration interface.

### 0.24.1 / 2017-04-21

* If Rails integration fails due to an auth error, the notice is now printed to STDOUT rather than STDERR, which should make it a bit less scary when displayed in Docker output.

### 0.24.0 / 2017-03-31

* Updated documentation
* Automatic retry on `UNAVAILABLE` errors

### 0.23.2 / 2017-03-03

* Update GRPC header value sent to the Trace API.

### 0.23.1 / 2017-03-01

* Update GRPC header value sent to the Trace API.

### 0.23.0 / 2017-02-21

* Fix GRPC retry bug
* The client_config data structure has replaced retry_codes/retry_codes_def with retry_codes
* Update GRPC/Protobuf/GAX dependencies

### 0.22.0 / 2017-01-27

* Change class names in low-level API (GAPIC)

### 0.21.0 / 2016-12-22

* Initial release of google-cloud-trace, providing an API client and application instrumentation.
