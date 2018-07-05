# Release History

### 0.32.1 / 2018-07-05

* Fix issue when disabling Stackdriver components with Rails.env.production.
* Add documentation for enabling gRPC logging.

### 0.32.0 / 2018-05-24

* Delay starting the debugger agent until the first request to ensure it
  happens after workers are forked. Should prevent grpc from malfunctioning in
  this case.

### 0.31.0 / 2018-02-27

* Use Google Cloud Shared Configuration.
* Fix for mutation detection using Ruby 2.5.
* Support disabling mutation detection in debugger evaluation.

### 0.30.0 / 2017-12-19

* Update google-gax dependency to 1.0.

### 0.29.1 / 2017-11-15

* Fix credentials verification bug in Railtie.

### 0.29.0 / 2017-11-14

* Add `Google::Cloud::Debugger::Credentials` class.
* Rename constructor arguments to `project_id` and `credentials`.
  (The previous arguments `project` and `keyfile` are still supported.)
* Document `Google::Auth::Credentials` as `credentials` value.
* Add Debugger Agent Design Document.
* Updated `google-gax` (`grpc`, `google-protobuf`), `googleauth` dependencies.

### 0.28.2 / 2017-09-28

* Improve Breakpoint tracer performance by not tracking C function calls in file tracing.
* Add a backoff behavior in the debuggee registration to reduce spamming requests when registrations fail.

### 0.28.1 / 2017-09-08

* Print captured exception from asynchronous worker threads.

### 0.28.0 / 2017-08-25

* Support single file Rack-based applications.
* Support none-Rack-based Ruby applications.
* API Breaking Change:
    * `module_name` initialization parameter renamed to `service_name`
    * `module_version` initialization parameter renamed to `module_version`

### 0.27.0 / 2017-08-07

* Optimize breakpoint evaluation memory usage by adopting shared variable table.
* Update breakpoint to error state if the breakpoint is set at an invalid position or
    if condition evaluation fail with an error.
* Set errored variable evaluation to error state.
* Restrict the amount of time spent on evaluating breakpoints within each rack application request.
* Restrict total memory usage on collecting variables within each breakpoint evaluation. Prioritize
    memory allocation to user defined variables over local variables.

### 0.26.1 / 2017-07-11

* stackdriver-core 1.2.0 release

### 0.26.0 / 2017-07-11

* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.

### 0.25.0 / 2017-05-25

* Introduce new `Google::Cloud::Debugger.configure` instrumentation configuration interface.

### 0.24.1 / 2017-04-07

* Fixed Google::Cloud::Debugger::Railtie initialization on non-GCP environments
    to not interfere with Rails startup

### 0.24.0 / 2017-04-06

* First release
