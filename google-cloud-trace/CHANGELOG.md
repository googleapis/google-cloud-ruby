# Release History

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
