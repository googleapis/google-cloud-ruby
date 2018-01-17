# Stackdriver Instrumentation Configuration

Stackdriver instrumentation libraries are fully integrated with Rails
configuration interface. You can provide all the configuration parameters in
your `config/environments/*.rb` files:

```ruby
Rails.application.configure do |config|
  # Shared project_id and keyfile
  config.google_cloud.project_id = "my-project"
  config.google_cloud.keyfile = "/path/to/key.json"

  # Library specific configurations
  config.google_cloud.error_reporting.project_id = "error-reporting-project"
  config.google_cloud.logging.log_name = "my-app-logname"
  config.google_cloud.trace.capture_stack = true
end
```

Other Rack-based applications can also configure all the Stackdriver
instrumentation libraries through a similar configuration interface in Ruby:

```ruby
Google::Cloud.configure do |config|
  # Shared project_id and keyfile
  config.project_id = "my-project"
  config.keyfile = "/path/to/key.json"

  # Library specific configurations
  config.error_reporting.project_id = "error-reporting-project"
  config.logging.log_name = "my-app-log"
  config.trace.capture_stack = true
end
```

Individual libraries can be configured separately:

```ruby
# Error Reporting specific configurations
Google::Cloud::ErrorReporting.configure do |config|
  config.project_id = "error-reporting-project"
  config.service_name = "my-service"
end

# Debugger specific configurations
Google::Cloud::Debugger.configure do |config|
  config.project_id = "debugger-project"
  config.service_name = "my-service"
  config.allow_mutating_methods = true
end

# Logging specific configurations
Google::Cloud::Logging.configure do |config|
  config.project_id = "error-reporting-project"
  config.log_name = "my-app-log"
  config.google_cloud.labels = {
    "my-static-label" => "static-label-value",
    "my-dynamic-label" => ->(rack_env) { rack_env["HTTP_X_MY_HEADER"] }
  }
end

# Trace specific configurations
Google::Cloud::Trace.configure do |config|
  config.project_id = "error-reporting-project"
  config.capture_stack = true
end
```

## Configuration Options

#### Shared

* `project_id`: [`String`] Shared Google Cloud Platform Project identifier. Self discovered on GCP.
* `credentials`: [`String`] Path to shared service account JSON keyfile. Self discovered on GCP.
* `use_error_reporting`: [`Boolean`] Explicitly enable or disable Error Reporting features. Default: `Rails.env.production?`
* `use_debugger`: [`Boolean`] Explicitly enable or disable Debugger features. Default: `Rails.env.production?`
* `use_logging`: [`Boolean`] Explicitly enable or disable Logging features. Default: `Rails.env.production?`
* `use_trace`: [`Boolean`] Explicitly enable or disable Trace features. Default: `Rails.env.production?`

#### Error Reporting

* `error_reporting.project_id`: [`String`] Google Cloud Platform Project identifier just for Error Reporting. Self discovered on GCP.
* `error_reporting.credentials`: [`String`] Path to service account JSON keyfile. Self discovered on GCP.
* `error_reporting.service_name`: [`String`] Identifier to running service. Self discovered on GCP. Default: `"ruby"`
* `error_reporting.service_version`: [`String`] Version identifier to running service. Self discovered on GCP.
* `error_reporting.ignore_classes`: [`Array`] An Array of Exception classes to ignore. Default: `[]`

#### Debugger

* `debugger.project_id`: [`String`] Google Cloud Platform Project identifier just for Debugger. Self discovered on GCP.
* `debugger.credentials`: [`String`] Path to service account JSON keyfile. Self discovered on GCP.
* `debugger.service_name`: [`String`] Identifier to running service. Self discovered on GCP. Default: `"ruby-app"`
* `debugger.service_version`: [`String`] Version identifier to running service. Self discovered on GCP.
* `debugger.root`: [`String`] The root directory of the debuggee application in absolute file path form. Default: `Rack::Directory#root` if the application framework is rack-based,i.e. Ruby on Rails, Sinatra. Otherwise use current working directory.
* `debugger.allow_mutating_methods`: [`boolean`] Whether to allow expressions to call methods that could mutate program state. Default is `false`.
* `debugger.evaluation_time_limit`: [`Numeric`] The time limit in seconds for evaluating expressions. Default is `0.05`.

#### Logging

* `logging.project_id`: [`String`] Google Cloud Platform Project identifier just for Logging. Self discovered on GCP.
* `logging.credentials`: [`String`] Path to service account JSON keyfile. Self discovered on GCP.
* `logging.log_name`: [`String`] Name of the application log file. Default: `"ruby_app_log"`
* `logging.log_name_map`: [`Hash`] Map specific request routes to other log. Default: `{ "/_ah/health" => "ruby_health_check_log" }`
* `logging.monitored_resource.type`: [`String`] Resource type name. See [full list](https://cloud.google.com/logging/docs/api/v2/resource-list). Self discovered on GCP.
* `logging.monitored_resource.labels`: [`Hash`] Resource labels. See [full list](https://cloud.google.com/logging/docs/api/v2/resource-list). Self discovered on GCP.
* `logging.labels`: [`Hash`] User defined labels. A `Hash` of label names to string label values or callables/`Proc` which are functions of the Rack environment.

#### Trace

* `trace.project_id`: [`String`] Google Cloud Platform Project identifier just for Trace. Self discovered on GCP.
* `trace.credentials`: [`String`] Path to service account JSON keyfile. Self discovered on GCP.
* `trace.capture_stack`: [`Boolean`] Whether to capture stack traces for each span. Default: `false`
* `trace.sampler`: [`Proc`] A sampler Proc makes the decision whether to record a trace for each request. Default: `Google::Cloud::Trace::TimeSampler`
* `trace.span_id_generator`: [`Proc`] A generator Proc that generates the name String for new TraceRecord. Default: `random numbers`
* `trace.notifications`: [`Array`] An array of ActiveSupport notification types to include in traces. Rails-only option. Default: `Google::Cloud::Trace::Railtie::DEFAULT_NOTIFICATIONS`
* `trace.max_data_length`: [`Integer`] The maximum length of span properties recorded with ActiveSupport notification events. Rails-only option. Default: `Google::Cloud::Trace::Notifications::DEFAULT_MAX_DATA_LENGTH`
