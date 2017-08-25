# Release History

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
