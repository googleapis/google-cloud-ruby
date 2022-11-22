# Release History

### 0.42.2 / 2021-10-21

#### Documentation

* Add documentation for quota_project Configuration attribute

### 0.42.1 / 2021-07-08

#### Documentation

* Update AUTHENTICATION.md in handwritten packages

### 0.42.0 / 2021-03-31

#### Features

* Drop support for Ruby 2.4 and note that Ruby 3.0 is also unsupported

### 0.41.0 / 2020-09-16

#### Features

* quota_project can be set via library configuration

### 0.40.0 / 2020-07-21

This is a major update that removes the "low-level" client interface code, and
instead adds the new `google-cloud-debugger-v2` gem as a dependency.
The new dependency is a rewritten low-level client, produced by a next-
generation client code generator, with improved performance and stability.

This change should have no effect on the high-level interface that most users
will use. The one exception is that the (mostly undocumented) `client_config`
argument, for adjusting low-level parameters such as RPC retry settings on
client objects, has been removed. If you need to adjust these parameters, use
the configuration interface in `google-cloud-debugger-v2`.

Substantial changes have been made in the low-level interfaces, however. If you
are using the low-level classes under the `Google::Cloud::Debugger::V2` module,
please review the docs for the new `google-cloud-debugger-v2` gem. In
particular:

* Some classes have been renamed, notably the client class itself.
* The client constructor takes a configuration block instead of configuration
  keyword arguments.
* All RPC method arguments are now keyword arguments.

### 0.36.3 / 2020-07-06

#### Bug Fixes

* Fix segfaults on Ruby 2.7

### 0.36.2 / 2020-05-28

#### Documentation

* Fix a few broken links

### 0.36.1 / 2020-05-19

#### Bug Fixes

* Adjusted some default timeout and retry settings

### 0.36.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.35.2 / 2020-01-23

#### Documentation

* Update copyright year

### 0.35.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.35.0 / 2019-10-29

This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform environments support automatic authentication

#### Performance Improvements

* Update lower-level client network configuration

### 0.34.0 / 2019-08-23

#### Features

* Support overriding of service endpoint

### 0.33.7 / 2019-07-31

* Fix max threads setting in thread pools
  * Thread pools once again limit the number of threads allocated.
* Update documentation links

### 0.33.6 / 2019-07-08

* Support overriding service host and port in the low-level client.

### 0.33.5 / 2019-06-11

* Google::Cloud::Env provides additional configuration options including retries and cache control
* Add VERSION constant

### 0.33.4 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update documentation for common types.
* Extract gRPC header values from request.

### 0.33.3 / 2019-02-13

* Fix bug (typo) in retrieving default on_error proc.

### 0.33.2 / 2019-02-08

* Fix conversion code for ErrorEvent and Debugee.
  * Prepare for changes in JSON serialization coming in
    google-protobuf 3.7.

### 0.33.1 / 2019-02-07

* Update concurrent-ruby dependency

### 0.33.0 / 2019-02-01

* Add Debugger on_error configuration.
* Update Transmitter
  * Add dependency on current-ruby.
  * Add Transmitter#on_error method.
  * Update Transmitter documentation.
* Make use of Credentials#project_id
  * Use Credentials#project_id
    If a project_id is not provided, use the value on the Credentials object.
    This value was added in googleauth 0.7.0.
  * Loosen googleauth dependency
    Allow for new releases up to 0.10.
    The googleauth devs have committed to maintaining the current API
    and will not make backwards compatible changes before 0.10.

### 0.32.6 / 2018-11-15

* Update network configuration.

### 0.32.5 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.
* Fix circular require warning.

### 0.32.4 / 2018-09-12

* Add missing documentation files to package.

### 0.32.3 / 2018-09-10

* Update documentation.

### 0.32.2 / 2018-08-21

* Update documentation.

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
